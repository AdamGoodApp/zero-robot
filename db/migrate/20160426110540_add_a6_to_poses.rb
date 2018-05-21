class AddA6ToPoses < ActiveRecord::Migration
  def change
    add_column :poses, :a6, :float
  end
end
