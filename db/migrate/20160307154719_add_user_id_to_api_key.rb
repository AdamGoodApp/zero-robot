class AddUserIdToApiKey < ActiveRecord::Migration
  def change
    add_column :api_keys, :user_id, :integer
    add_index :api_keys, :user_id
  end
end
