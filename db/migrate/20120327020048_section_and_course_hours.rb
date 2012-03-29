class SectionAndCourseHours < ActiveRecord::Migration
  def up
    add_column :courses, :hours_min, :integer
    add_column :courses, :hours_max, :integer
    add_column :sections, :hours, :integer
    remove_column :courses, :credit_hours
  end

  def down
    remove_column :courses, :hours_min
    remove_column :courses, :hours_max
    remove_column :sections, :hours
    add_column :courses, :credit_hours, :integer
  end
end
