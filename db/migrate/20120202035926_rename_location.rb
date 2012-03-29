class RenameLocation < ActiveRecord::Migration
  def up
    rename_table :locations, :buildings
    remove_column :sections, :location_id
  end

  def down
    rename_table :buildings, :locations
    add_column :sections, :location_id, :integer
  end
end
