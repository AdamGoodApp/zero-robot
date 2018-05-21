class ChangeWeightToSpeed < ActiveRecord::Migration
  def change
    rename_column :toolpaths, :weight, :speed
  end
end
