class DropRobotToolpathsTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :robot_toolpaths
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
