class AddCreatedAtAndUpdatedAtToToolpathWaypoints < ActiveRecord::Migration
  def change
    add_column :toolpath_waypoints, :created_at, :datetime
    add_column :toolpath_waypoints, :updated_at, :datetime
  end
end
