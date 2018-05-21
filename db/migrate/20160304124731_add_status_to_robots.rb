class AddStatusToRobots < ActiveRecord::Migration
  def change
    add_column :robots, :status, :string
  end
end
