class CreateSegmentWaypoints < ActiveRecord::Migration
  def change
    create_table :segment_waypoints do |t|
      t.integer :segment_id
      t.integer :waypoint_id
    end
    add_index :segment_waypoints, :segment_id
    add_index :segment_waypoints, :waypoint_id
  end
end
