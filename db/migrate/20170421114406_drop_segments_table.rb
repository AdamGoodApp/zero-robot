class DropSegmentsTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :segments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
