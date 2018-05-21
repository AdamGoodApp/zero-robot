class DropSegmentWaypointsTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :segment_waypoints
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
