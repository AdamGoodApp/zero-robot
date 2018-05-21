class AddSpeedToToolpaths < ActiveRecord::Migration
  def change
    add_column :toolpaths, :weight, :string
  end
end
