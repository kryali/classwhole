class RenameAttribute < ActiveRecord::Migration
  def up
    rename_column :geneds_attributes, :attributes_id, :attribs_id
    rename_table :attributes, :attribs
    rename_table :geneds_attributes, :geneds_attribs
  end

  def down
  end
end
