class AddCourseCodeToSections < ActiveRecord::Migration
  def change
    add_column :sections, :course_code, :string
    add_column :sections, :course_title, :string
  end
end
