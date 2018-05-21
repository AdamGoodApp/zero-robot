class DropPosesTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :poses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
