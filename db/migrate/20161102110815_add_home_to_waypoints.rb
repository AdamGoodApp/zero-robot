class AddHomeToWaypoints < ActiveRecord::Migration[5.0]
  def change
    add_column :waypoints, :home, :boolean
  end
end
