class ALine

  attr_accessor :st, :en

  def initialize(start_pt=GeoFunctions.origin, end_pt=GeoFunctions.origin)
    @st = start_pt
    @en = end_pt
  end

  def is_valid?
    !@st.is_valid? || !@en.is_valid? ? false : true
  end

  def direction
    AVector.new(@st, @en)
  end

end