class CreateMeetings < ActiveRecord::Migration
  def up
    create_table :meetings do |t|
      t.string :type
      t.time :start_time
      t.time :end_time
      t.string :days
      t.string :room
      t.integer :building_id
    end
  end

  def down
    drop_table :meetings
  end
end
