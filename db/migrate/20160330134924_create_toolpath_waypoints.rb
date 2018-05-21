class CreateToolpathWaypoints < ActiveRecord::Migration
  def change
    create_table :toolpath_waypoints do |t|
      t.integer :toolpath_id
      t.integer :waypoint_id
    end
    add_index :toolpath_waypoints, :toolpath_id
    add_index :toolpath_waypoints, :waypoint_id
  end
end
