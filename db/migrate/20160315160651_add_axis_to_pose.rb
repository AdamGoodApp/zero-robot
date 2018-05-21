class AddAxisToPose < ActiveRecord::Migration
  def change
    add_column :poses, :a0, :float
    add_column :poses, :a1, :float
    add_column :poses, :a2, :float
    add_column :poses, :a3, :float
    add_column :poses, :a4, :float
    add_column :poses, :a5, :float
  end
end
