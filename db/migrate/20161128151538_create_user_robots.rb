class CreateUserRobots < ActiveRecord::Migration[5.0]
  def change
    create_table :user_robots do |t|
      t.integer :user_id
      t.integer :robot_id
    end
    add_index :user_robots, :user_id
    add_index :user_robots, :robot_id
  end
end
