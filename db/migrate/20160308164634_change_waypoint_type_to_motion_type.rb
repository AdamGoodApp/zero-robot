class ChangeWaypointTypeToMotionType < ActiveRecord::Migration
  def change
    rename_column :waypoints, :type, :motion_type
  end
end
