class AddNameToToolpaths < ActiveRecord::Migration[5.0]
  def change
    add_column :toolpaths, :name, :string
  end
end
