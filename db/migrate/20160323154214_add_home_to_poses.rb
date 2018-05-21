class AddHomeToPoses < ActiveRecord::Migration
  def change
    add_column :poses, :home, :bool
  end
end
