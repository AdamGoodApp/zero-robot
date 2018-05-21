class AddToolTypeToToolpathWaypoints < ActiveRecord::Migration
  def change
    add_column :toolpath_waypoints, :tool_type, :string
  end
end
