class AInterval

  attr_accessor :t0, :t1

  def initialize(t0 = nil, t1 = nil)
    @t0 = t0
    @t1 = t1
  end

  def min()
    [@t0, @t1].min
  end

  def max()
    [@t0, @t1].max
  end

  def includes_parameter?(val)
    val >= @t0 && val <= @t1 ? true : false
  end

end