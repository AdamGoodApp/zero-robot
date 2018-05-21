class AddWeightToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :weight, :float
  end
end
