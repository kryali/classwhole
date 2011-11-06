class RemovingScheduleTable < ActiveRecord::Migration
  def up
    drop_table :schedules
    remove_column :users, :schedule_id
  end

  def down
  end
end
