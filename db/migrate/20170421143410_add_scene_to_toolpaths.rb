class AddSceneToToolpaths < ActiveRecord::Migration[5.0]
  def change
    add_column :toolpaths, :scene, :text, :limit => 4294967295
  end
end
