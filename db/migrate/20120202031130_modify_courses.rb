class ModifyCourses < ActiveRecord::Migration
  def up
    rename_column :courses, :hours, :credit_hours
    add_column :courses, :section_information, :text
    add_column :courses, :schedule_information, :text
    remove_column :courses, :user_id
  end

  def down
    rename_column :courses, :hours, :credit_hours
    remove_column :courses, :section_information
    remove_column :courses, :schedule_information
    add_column :courses, :user_id, :integer
  end
end
