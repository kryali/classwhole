class AddingSemesterBeginAndEndDate < ActiveRecord::Migration
  #lol jk i meant section not semester
  def up
    add_column :sections, :start_date, :datetime
    add_column :sections, :end_date, :datetime
  end

  def down
    remove_column :sections, :start_date
    remove_column :sections, :end_date
  end
end
