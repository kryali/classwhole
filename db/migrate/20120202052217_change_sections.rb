class ChangeSections < ActiveRecord::Migration
  def up
    rename_column :geneds_courses, :geneds_id, :gened_id
    rename_column :geneds_courses, :courses_id, :course_id
  end

  def down
  end
end
