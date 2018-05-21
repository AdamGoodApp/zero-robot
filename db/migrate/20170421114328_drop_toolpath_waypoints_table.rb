class DropToolpathWaypointsTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :toolpath_waypoints
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
