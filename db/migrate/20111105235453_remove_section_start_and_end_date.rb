class RemoveSectionStartAndEndDate < ActiveRecord::Migration
  def change
    remove_column :sections, :start_date
    remove_column :sections, :end_date
  end
end
