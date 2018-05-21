class AddDefaultValueToHome < ActiveRecord::Migration
  def change
    change_column :robots, :home, :boolean, :default => true
  end
end
