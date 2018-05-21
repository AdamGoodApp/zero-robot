class AddSegmentTimeAndTimestepToSegment < ActiveRecord::Migration
  def change
    add_column :segments, :segment_time, :float
    add_column :segments, :timestep, :float
  end
end
