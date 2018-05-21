class AddPositionToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :position, :integer
  end
end
