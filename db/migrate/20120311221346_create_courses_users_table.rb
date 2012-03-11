class CreateCoursesUsersTable < ActiveRecord::Migration

  def change
    drop_table "users_courses"
    create_table "courses_users", :id => false, :force => true do |t|
      t.integer "user_id"
      t.integer "course_id"
    end
  end

end
