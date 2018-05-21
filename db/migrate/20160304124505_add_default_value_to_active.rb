class AddDefaultValueToActive < ActiveRecord::Migration
  def change
    change_column :robots, :active, :boolean, :default => false
  end
end
