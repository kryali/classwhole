class ChangeMeetingInstructorsName < ActiveRecord::Migration
  def up
    drop_table :meetings_instructors
    create_table "instructors_meetings", :id => false, :force => true do |t|
      t.integer "meeting_id"
      t.integer "instructor_id"
    end  
  end
 
  def down
  end
end
