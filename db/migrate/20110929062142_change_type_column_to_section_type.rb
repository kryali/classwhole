class ChangeTypeColumnToSectionType < ActiveRecord::Migration
  def up
    rename_column :sections, :type, :section_type
  end

  def down
    rename_column :sections, :section_type, :type
  end
end
