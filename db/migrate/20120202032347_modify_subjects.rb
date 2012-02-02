class ModifySubjects < ActiveRecord::Migration
  def up
    add_column :subjects, :address1, :string
    remove_column :subjects, :unit_name
  end

  def down
    remove_column :subjects, :address1
    add_column :subjects, :unit_name, :string
  end
end
