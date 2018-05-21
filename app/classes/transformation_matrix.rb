require "matrix"

class TransformationMatrix

  attr_accessor :alpha, :a, :d, :theta, :M

  def initialize(alpha,a,d,theta)
    @alpha = alpha
    @a = a
    @d = d
    @theta = theta
    @M = nil
    self.build()
  end


  def build
    @M = Matrix.zero(4,4)
    set_value(0, 0, Math.cos(@theta))
    set_value(0, 1, -Math.sin(@theta))
    set_value(0, 3, @a)
    set_value(1, 0, Math.sin(@theta)*Math.cos(@alpha))
    set_value(1, 1, Math.cos(@theta)*Math.cos(@alpha))
    set_value(1, 2, -Math.sin(@alpha))
    set_value(1, 3, -Math.sin(@alpha)*@d)
    set_value(2, 0, Math.sin(@theta)*Math.sin(@alpha))
    set_value(2, 1, Math.cos(@theta)*Math.sin(@alpha))
    set_value(2, 2, Math.cos(@alpha))
    set_value(2, 3, Math.cos(@alpha)*@d)
    set_value(3,3,1)
  end

  private

  def set_value(col, row, val)
    @M.send(:[]=, col, row, val)
  end



end