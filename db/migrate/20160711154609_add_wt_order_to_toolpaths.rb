class AddWtOrderToToolpaths < ActiveRecord::Migration
  def change
    add_column :toolpaths, :wt_order, :string
  end
end
