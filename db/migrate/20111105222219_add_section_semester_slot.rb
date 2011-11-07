class AddSectionSemesterSlot < ActiveRecord::Migration
  def up
    add_column :sections, :semester_slot, :int, :default => 0
  end
  def down
    remove_column :sections, :semester_slot
  end
end
