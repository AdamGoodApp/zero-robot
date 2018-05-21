class ChangeToolpathWtOrderToText < ActiveRecord::Migration[5.0]
  def change
    change_column :toolpaths, :wt_order, :text
  end
end
