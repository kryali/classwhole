class AddSchoolId < ActiveRecord::Migration
  def up
    add_column :semesters, :school_id, :integer
  end

  def down
    remove_column :semesters, :school_id
  end
end
