class CreateRobotToolpaths < ActiveRecord::Migration
  def change
    create_table :robot_toolpaths do |t|
      t.integer :robot_id
      t.integer :toolpath_id
    end
    add_index :robot_toolpaths, :robot_id
    add_index :robot_toolpaths, :toolpath_id
  end
end
