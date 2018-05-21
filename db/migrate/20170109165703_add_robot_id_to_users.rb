class AddRobotIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :robot_id, :integer
    add_index :users, :robot_id
  end
end
