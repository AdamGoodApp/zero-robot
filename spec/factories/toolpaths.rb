FactoryGirl.define do
  factory :toolpath do
    name 'Spray'
    scene '{"metadata":{"speed":1},"waypoints":[{"type":1,"color":"#AD7A14","rotations":[0,0,0,-1.5707963267948966,-1.5707963267948966,0]},{"type":1,"color":"#783321","rotations":[2.6012614284809388e-8,-0.5924197435379028,-4.920686080822634e-10,-2.6306607723236084,0.08148782700300217,2.5653537960579342e-8]},{"type":2,"color":"#730154","rotations":[4.84063988892558e-9,-0.7594678997993469,1.81546527810994e-10,-0.7925286889076233,-1.5895962715148926,5.366084909752544e-9]}],"timeline":[{"type":"waypoint","waypointId":0},{"type":"waypoint","waypointId":2,"weight":0.5},{"type":"waypoint","waypointId":1},{"type":"waypoint","waypointId":0}]}'
    user_id 1
  end
end