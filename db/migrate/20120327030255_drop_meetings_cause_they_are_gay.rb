class DropMeetingsCauseTheyAreGay < ActiveRecord::Migration
  def up
    drop_table :meetings
  end

  def down
  end
end
