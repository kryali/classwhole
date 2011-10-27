class AddCourseNumberToSections < ActiveRecord::Migration
  def up
    add_column :sections, :course_number, :integer
  end

  def down
    remove_column :sections, :course_number
  end
end
