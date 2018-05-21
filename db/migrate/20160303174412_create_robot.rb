class CreateRobot < ActiveRecord::Migration
  def change
    create_table :robots do |t|
      t.boolean :home
    end
  end
end
