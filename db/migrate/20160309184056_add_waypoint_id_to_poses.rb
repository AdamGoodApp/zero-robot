class AddWaypointIdToPoses < ActiveRecord::Migration
  def change
    add_column :poses, :waypoint_id, :integer
    add_index :poses, :waypoint_id
  end
end
