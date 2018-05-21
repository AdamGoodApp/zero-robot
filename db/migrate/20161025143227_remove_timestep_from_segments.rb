class RemoveTimestepFromSegments < ActiveRecord::Migration[5.0]
  def change
    remove_column :segments, :timestep
  end
end
