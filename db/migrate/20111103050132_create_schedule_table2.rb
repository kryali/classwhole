class CreateScheduleTable2 < ActiveRecord::Migration
  def up
    create_table :schedules do |t|
      t.references :user
      t.references :sections
    end
  end

  def down
    drop_table :schedules
  end
end
