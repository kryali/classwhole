class RemoveSFromANameAgain < ActiveRecord::Migration
  def up
    rename_column :attribs_geneds, :geneds_id, :gened_id
    rename_column :attribs_geneds, :attribs_id, :attrib_id
  end

  def down
  end
end
