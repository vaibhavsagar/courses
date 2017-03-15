package kvstore

import akka.actor.Props
import akka.actor.Actor
import akka.actor.ActorRef
import akka.actor.ReceiveTimeout
import scala.concurrent.duration._
import scala.language.postfixOps

object Replicator {
  case class Replicate(key: String, valueOption: Option[String], id: Long)
  case class Replicated(key: String, id: Long)
  
  case class Snapshot(key: String, valueOption: Option[String], seq: Long)
  case class SnapshotAck(key: String, seq: Long)

  def props(replica: ActorRef): Props = Props(new Replicator(replica))
}

class Replicator(val replica: ActorRef) extends Actor {
  import Replicator._
  import Replica._
  import context.dispatcher
  
  /*
   * The contents of this actor is just a suggestion, you can implement it in any way you like.
   */

  // map from sequence number to pair of sender and request
  var acks = Map.empty[Long, (ActorRef, Replicate)]
  // a sequence of not-yet-sent snapshots (you can disregard this if not implementing batching)
  var pending = Vector.empty[Snapshot]
  // map from sequence number to id
  var seqToId = Map.empty[Long, Long]
  
  var _seqCounter = 0L
  def nextSeq = {
    val ret = _seqCounter
    _seqCounter += 1
    ret
  }

  
  /* TODO Behavior for the Replicator. */
  def receive: Receive = {
    case Replicate(key, valueOption, id) =>
      val resender = context.actorOf(ResendSnapshot.props(replica, 100 milliseconds))
      val seq = nextSeq
      seqToId = seqToId + (seq -> id)
      resender ! Snapshot(key, valueOption, seq)
    case SnapshotAck(key, seq) =>
      context.parent ! Replicated(key, seqToId(seq))
  }

}

object ResendSnapshot {
  def props(replica: ActorRef, timeout: Duration): Props = Props(new ResendSnapshot(replica, timeout))
}

class ResendSnapshot(val replica: ActorRef, val timeout: Duration) extends Actor {
  import Replicator._  
  
  def receive: Receive = {
    case message @ Snapshot(key, valueOption, seq) =>
      replica ! message
      context.setReceiveTimeout(timeout)
      context.become(resend(message))
  }
  
  def resend(message: Snapshot): Receive = {
    case msg @ SnapshotAck(key, seq) =>
      context.parent ! msg
      context.stop(self)
    case ReceiveTimeout =>
      replica ! message   
  }
  
}