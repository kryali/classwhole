class MeetingsTable < ActiveRecord::Migration
  def change
    drop_table :sections_meetings
    
    create_table :meetings do |t|
      t.references :section # creates section_id
      t.time :start_time
      t.time :end_time
      t.string :room_number
      t.string :days
      t.string :class_type
      t.string :building
      t.string :short_type
    end
    add_index :meetings, :section_id
    
    create_table :instructors do |t|
      t.string :name
      t.float :easy
      t.float :avg
      t.integer :num_ratings
    end
    add_index :instructors, :name
    
    create_table :instructors_meetings, :id => false, :force => true do |t|
      t.references :instructors, :null => false
      t.references :meetings, :null => false
    end
    add_index(:meetings_instructors, [:meetings, :orange_id], :unique => true)
    
  end
  
end