class ConfigurationCourseAndSection < ActiveRecord::Migration
  def up
    add_column :configurations, :course_number, :integer
    add_column :configurations, :subject, :string
  end

  def down
    remove_column :configurations, :course_number
    remove_column :configurations, :subject
  end
end
