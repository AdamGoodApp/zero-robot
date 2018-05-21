describe Segment do

  let(:waypoints) { [[{"type"=>"waypoint", "waypointId"=>0}, {:motion=>"linear", :rotations=>[0, 0, 0, -1.5707963267948966, -1.5707963267948966, 0]}], [{"type"=>"waypoint", "waypointId"=>2, "weight"=>0.5}, {:motion=>"interpolation", :rotations=>[4.84063988892558e-09, -0.7594678997993469, 1.81546527810994e-10, -0.7925286889076233, -1.5895962715148926, 5.366084909752544e-09]}], [{"type"=>"waypoint", "waypointId"=>0}, {:motion=>"linear", :rotations=>[0, 0, 0, -1.5707963267948966, -1.5707963267948966, 0]}], [{"type"=>"waypoint", "waypointId"=>1}, {:motion=>"linear", :rotations=>[2.6012614284809388e-08, -0.5924197435379028, -4.920686080822634e-10, -2.6306607723236084, 0.08148782700300217, 2.5653537960579342e-08]}]] }
  let(:finished_segments) { [{:speed=>3.0, :weight=>0.5, :waypoints=>[[{"type"=>"waypoint", "waypointId"=>0}, {:motion=>"linear", :rotations=>[0, 0, 0, -1.5707963267948966, -1.5707963267948966, 0]}], [{"type"=>"waypoint", "waypointId"=>2, "weight"=>0.5}, {:motion=>"interpolation", :rotations=>[4.84063988892558e-09, -0.7594678997993469, 1.81546527810994e-10, -0.7925286889076233, -1.5895962715148926, 5.366084909752544e-09]}], [{"type"=>"waypoint", "waypointId"=>0}, {:motion=>"linear", :rotations=>[0, 0, 0, -1.5707963267948966, -1.5707963267948966, 0]}]]}, {:speed=>3.0, :weight=>0.5, :waypoints=>[[{"type"=>"waypoint", "waypointId"=>0}, {:motion=>"linear", :rotations=>[0, 0, 0, -1.5707963267948966, -1.5707963267948966, 0]}], [{"type"=>"waypoint", "waypointId"=>1}, {:motion=>"linear", :rotations=>[2.6012614284809388e-08, -0.5924197435379028, -4.920686080822634e-10, -2.6306607723236084, 0.08148782700300217, 2.5653537960579342e-08]}]]}] }

  context '.split to segments' do
    it 'returns segments' do
      expect(Segment.split_to_segments(waypoints)).to eq(finished_segments)
    end
  end

end