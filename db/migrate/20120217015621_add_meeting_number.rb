class AddMeetingNumber < ActiveRecord::Migration
  def up
    add_column :meetings, :meeting_number, :integer
  end

  def down
    remove_column :meetings, :meeting_number
  end
end
