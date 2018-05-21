class AddPositionToToolpathWaypoints < ActiveRecord::Migration
  def change
    add_column :toolpath_waypoints, :position, :integer
  end
end
