class CreateWaypoint < ActiveRecord::Migration
  def change
    create_table :waypoints do |t|
      t.string :type
      t.string :color
      t.integer :robot_id
    end
    add_index :waypoints, :robot_id
  end
end
