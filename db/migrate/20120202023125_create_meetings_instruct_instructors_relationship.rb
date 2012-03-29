class CreateMeetingsInstructInstructorsRelationship < ActiveRecord::Migration
  def up
    create_table :meetings_instructors, :id => false do |t|
      t.integer :meetings_id
      t.integer :instructors_id
    end
  end

  def down
    drop_table :meetings_instructors
  end
end
