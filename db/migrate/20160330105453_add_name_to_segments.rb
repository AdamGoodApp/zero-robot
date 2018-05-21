class AddNameToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :name, :string
  end
end
