class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.integer :toolpath_id
    end
    add_index :segments, :toolpath_id
  end
end
