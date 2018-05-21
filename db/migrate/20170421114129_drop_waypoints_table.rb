class DropWaypointsTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :waypoints
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
