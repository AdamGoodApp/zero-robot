class AddCreatedAtAndUpdatedAtToWaypoints < ActiveRecord::Migration
  def change
    add_column :waypoints, :created_at, :datetime
    add_column :waypoints, :updated_at, :datetime
  end
end
