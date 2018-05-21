class CreateToolsTable < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.string :tools_type
      t.integer :toolpath_id
    end
  end
end
