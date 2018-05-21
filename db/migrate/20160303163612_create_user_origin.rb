class CreateUserOrigin < ActiveRecord::Migration
  def change
    create_table :user_origins do |t|
      t.float :pos_x
      t.float :pos_y
      t.float :pos_z
      t.float :vec1_x
      t.float :vec1_y
      t.float :vec1_z
      t.float :vec2_x
      t.float :vec2_y
      t.float :vec2_z
      t.integer :robot_id
    end
    add_index :user_origins, :robot_id
  end
end
