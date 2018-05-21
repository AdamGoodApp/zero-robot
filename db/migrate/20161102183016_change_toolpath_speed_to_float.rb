class ChangeToolpathSpeedToFloat < ActiveRecord::Migration[5.0]
  def change
    change_column_null :toolpaths, :speed, :float
  end
end
