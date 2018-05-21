class AddUserIdToToolpaths < ActiveRecord::Migration[5.0]
  def change
    add_column :toolpaths, :user_id, :integer
    add_index :toolpaths, :user_id
  end
end
