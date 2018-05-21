class ChangeBackToSttring < ActiveRecord::Migration
  def change
    change_column :toolpaths, :speed, :string
  end
end
