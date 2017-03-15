package calculator

object Polynomial {
  def computeDelta(a: Signal[Double], b: Signal[Double],
      c: Signal[Double]): Signal[Double] = {
    Signal(math.pow(b(), 2) - (4 * a() * c()))
  }

  def computeSolutions(a: Signal[Double], b: Signal[Double],
      c: Signal[Double], delta: Signal[Double]): Signal[Set[Double]] = {
    Signal({
      if (delta()<0) Set()
      else computeRoots(a(), b(), delta())
    })
  }

  private def computeRoots(a: Double, b: Double, delta: Double): Set[Double] = {
    val sqrtDelta = math.pow(delta, 0.5)
    Set(
      ((-b+sqrtDelta)/(2*a)),
      ((-b-sqrtDelta)/(2*a))
    )
  }
}
