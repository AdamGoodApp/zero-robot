
class AQuaternion

  attr_accessor :q0 , :q1 , :q2 , :q3

  # X and Y can be an APoint Instance, x subs from and y subs to
  def initialize(q0=1, q1=0,q2=0, q3=0)

    @q0 = q0
    @q1 = q1
    @q2 = q2
    @q3 = q3

  end

  def length
    Math.sqrt(@q0 * @q0 + @q1 * @q1 + @q2 * @q2 + @q3 * @q3)
  end

  def normalize
    c_length = length
    AQuaternion.new(@q0 / c_length, @q1 / c_length, @q2 / c_length, @q3 / c_length)
  end

  def get_frame
    q0 = @q0
    q1 = @q1
    q2 = @q2
    q3 = @q3

    x1 = q0*q0+q1*q1-q2*q2-q3*q3
    x2 = 2*(q1*q2+q0*q3)
    x3 = 2*(q1*q3-q0*q2)
    v1= AVector.new(x1, x2, x3)

    y1 = 2*(q1*q2-q0*q3)
    y2 = q0*q0-q1*q1+q2*q2-q3*q3
    y3 = 2*(q2*q3+q0*q1)
    v2= AVector.new(y1, y2, y3)

    z1 = 2*(q1*q3+q0*q2)
    z2 = 2*(q2*q3-q0*q1)
    z3 = q0*q0-q1*q1-q2*q2+q3*q3
    v3= AVector.new(z1, z2, z3)

    p1=APoint.new
    APlane.new(p1, v1.normalize, v2.normalize, v3.normalize)
  end

end