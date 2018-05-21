class DropUserRobotsTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :user_robots
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
