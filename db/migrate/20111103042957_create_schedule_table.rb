class CreateScheduleTable < ActiveRecord::Migration
  def change
    add_column :users, :schedule_id, :int
  end
end
