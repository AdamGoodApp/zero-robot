class DropToolsTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :tools
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
