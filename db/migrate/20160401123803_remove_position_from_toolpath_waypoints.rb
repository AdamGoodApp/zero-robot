class RemovePositionFromToolpathWaypoints < ActiveRecord::Migration
  def change
    remove_column :toolpath_waypoints, :position
  end
end
