class AddStartDateToSections < ActiveRecord::Migration
  def up
    add_column :sections, :start_date, :datetime
    add_column :sections, :end_date, :datetime
  end

  def down
    remove_column :sections, :start_date, :datetime
    remove_column :sections, :end_date, :datetime
  end
end
