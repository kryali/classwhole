class CreateCoursesMeetingsRelationship < ActiveRecord::Migration
  def up
    create_table :sections_meetings, :id => false do |t|
      t.integer :sections_id
      t.integer :meetings_id
    end
  end

  def down
    drop_table :sections_meetings
  end
end
