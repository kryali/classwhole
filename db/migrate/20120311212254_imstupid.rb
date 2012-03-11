class Imstupid < ActiveRecord::Migration
  def up
    create_table 'users_courses', :id => false do |t|
      t.column :user_id, :integer
      t.column :course_id, :integer
    end
  end

  def down
    drop_table 'users_courses'
  end
end
