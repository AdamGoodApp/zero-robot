class RemoveUserIdFromRobots < ActiveRecord::Migration[5.0]
  def change
    remove_column :robots, :user_id
  end
end
