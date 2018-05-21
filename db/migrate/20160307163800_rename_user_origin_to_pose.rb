class RenameUserOriginToPose < ActiveRecord::Migration
  def change
    rename_table :user_origins, :pose
  end
end
