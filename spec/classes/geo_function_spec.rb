describe GeoFunctions do

  let(:p0) { APoint.new(1, 2, 3) }
  let(:p1) { APoint.new(4, 5, 6) }

  context '#plus point' do
    it 'returns plus point calculation' do
      point = APoint.new(p0.x + p1.x, p0.y + p1.y, p0.z + p1.z)
      expect(point.x).to eq(5)
      expect(point.y).to eq(7)
      expect(point.z).to eq(9)
    end
  end




end