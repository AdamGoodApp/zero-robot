class AddNameAndActiveToRobots < ActiveRecord::Migration
  def change
    add_column :robots, :name, :string
    add_column :robots, :active, :boolean
  end
end
