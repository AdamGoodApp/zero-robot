class RenamePoseTableToPosesTable < ActiveRecord::Migration
  def change
    rename_table :pose, :poses
  end
end
