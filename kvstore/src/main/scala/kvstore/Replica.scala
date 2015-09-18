package kvstore

import akka.actor.{ OneForOneStrategy, Props, ActorRef, Actor }
import kvstore.Arbiter._
import scala.collection.immutable.Queue
import akka.actor.SupervisorStrategy.Restart
import akka.actor.SupervisorStrategy.Escalate
import scala.annotation.tailrec
import akka.pattern.{ ask, pipe }
import akka.actor.Terminated
import scala.concurrent.duration._
import akka.actor.PoisonPill
import akka.actor.OneForOneStrategy
import akka.actor.SupervisorStrategy
import akka.util.Timeout
import akka.actor.OneForOneStrategy
import kvstore.Persistence._
import akka.actor.ReceiveTimeout
import scala.language.postfixOps
import akka.event.LoggingReceive

object Replica {
  sealed trait Operation {
    def key: String
    def id: Long
  }
  case class Insert(key: String, value: String, id: Long) extends Operation
  case class Remove(key: String, id: Long) extends Operation
  case class Get(key: String, id: Long) extends Operation

  sealed trait OperationReply
  case class OperationAck(id: Long) extends OperationReply
  case class OperationFailed(id: Long) extends OperationReply
  case class GetResult(key: String, valueOption: Option[String], id: Long) extends OperationReply

  def props(arbiter: ActorRef, persistenceProps: Props): Props = Props(new Replica(arbiter, persistenceProps))
}

class Replica(val arbiter: ActorRef, persistenceProps: Props) extends Actor {
  import Replica._
  import Replicator._
  import Persistence._
  import context.dispatcher

  /*
   * The contents of this actor is just a suggestion, you can implement it in any way you like.
   */
  
  var kv = Map.empty[String, String]
  // a map from secondary replicas to replicators
  var secondaries = Map.empty[ActorRef, ActorRef]
  // the current set of replicators
  var replicators = Set.empty[ActorRef]
  // the currently expected sequence number (for secondaries)
  var expected = 0L
  var resend = ActorRef.noSender
  
  arbiter ! Join

  override val supervisorStrategy = OneForOneStrategy(maxNrOfRetries = 10, withinTimeRange = 1 minute) {
    case exc: PersistenceException => Restart
    case _ => Escalate
  }
  
  val persister = context.actorOf(persistenceProps)

  def receive = {
    case JoinedPrimary   => context.become(leader)
    case JoinedSecondary => context.become(replica)
  }

  /* TODO Behavior for  the leader role. */
  val leader: Receive = {
    case message @ Insert(key, value, id) =>
      kv = kv + (key -> value)
      resend = context.actorOf(ResendPersistPrimary.props(sender, persister, replicators, 100 milliseconds))
      resend ! message
    case message @ Remove(key, id) =>
      kv = kv - key
      resend = context.actorOf(ResendPersistPrimary.props(sender, persister, replicators, 100 milliseconds))
      resend ! message
    case Get(key, id) =>
      sender ! GetResult(key, kv.get(key), id)
    case Replicas(replicas) =>
      val currentReplicas = secondaries.keySet + self
      val newReplicas = replicas -- currentReplicas
      val oldReplicas = currentReplicas -- replicas
      for (replica <- newReplicas) {
        val replicator = context.actorOf(Replicator.props(replica))
        replicators += replicator
        secondaries += (replica -> replicator)
        for ((key, value) <- kv) {
          replicator ! Replicate(key, Some(value), 0L)
        }
      }
      for (replica <- oldReplicas) {
        val replicator = secondaries(replica)
        replicator ! PoisonPill
        replicators -= replicator
        secondaries -= replica
      }
    case message : Replicated =>
      resend ! message
  }

  /* TODO Behavior for the replica role. */
  val replica: Receive = {
    case Get(key, id) =>
      sender ! GetResult(key, kv.get(key), id)
    case message @ Snapshot(key, valueOption, seq) =>
      if (seq > expected){
      } else if (seq < expected) {
        sender ! SnapshotAck(key, seq)
        expected = math.max(seq+1, expected)
      } else {
        valueOption match {
          case Some(value) => 
            kv = kv + (key -> value)
          case None =>
            kv = kv - key
        }
        val resend = context.actorOf(ResendPersistSecondary.props(sender, persister, 100 milliseconds))
        resend ! message
        expected = math.max(seq+1, expected)
      }   
  }
}

object ResendPersistPrimary {
  def props(client: ActorRef, persister: ActorRef, replicators: Set[ActorRef], timeout: Duration): Props = Props(new ResendPersistPrimary(client, persister, replicators, timeout))
}

class ResendPersistPrimary(val client: ActorRef, val persister: ActorRef, val replicators: Set[ActorRef], val timeout: Duration) extends Actor {
  import Replica._
  import Replicator._
  
  var timeouts = 0
  var replicatorAcks = 0
  var persisted = false
  
  def receive: Receive = {
    case Insert(key, value, id) =>
      val message = Persist(key, Some(value), id)
      for (replicator <- replicators) {
        replicator ! Replicate(key, Some(value), id)
      }
      persister ! message
      context.setReceiveTimeout(timeout)
      context.become(resend(message))
    case Remove(key, id) =>
      val message = Persist(key, None, id)
      for (replicator <- replicators) {
        replicator ! Replicate(key, None, id)
      }
      persister ! message
      context.setReceiveTimeout(timeout)
      context.become(resend(message))
  }
  
  def resend(message: Persist): Receive = {
    case msg: Persisted =>
      persisted = true
    case Replicated(key, id) =>
      replicatorAcks += 1
    case ReceiveTimeout if persisted && (replicators.size <= replicatorAcks) =>
      client ! OperationAck(message.id)
      context.stop(self)
    case ReceiveTimeout if timeouts < 10 =>
      timeouts += 1
      persister ! message
    case ReceiveTimeout if timeouts >= 10 =>
      client ! OperationFailed(message.id)
      context.stop(self)
  } 
}

object ResendPersistSecondary {
  def props(client: ActorRef, persister: ActorRef, timeout: Duration): Props = Props(new ResendPersistSecondary(client, persister, timeout))
}

class ResendPersistSecondary(val replicator: ActorRef, val persister: ActorRef, val timeout: Duration) extends Actor {
  import Replica._
  import Replicator._  
  
  def receive: Receive = {
    case Snapshot(key, valueOption, seq) =>
      val message = Persist(key, valueOption, seq)
      persister ! message
      context.setReceiveTimeout(timeout)
      context.become(resend(message, seq))
  }
  
  def resend(message: Persist, seq: Long): Receive = {
    case Persisted(key, id) =>
      replicator ! SnapshotAck(key, seq)
      context.stop(self)
    case ReceiveTimeout =>
      persister ! message
  } 
}

