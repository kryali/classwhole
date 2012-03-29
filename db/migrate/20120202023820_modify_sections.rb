class ModifySections < ActiveRecord::Migration
  def up
    add_column :sections, :location_id, :integer
    remove_column :sections, :room
    remove_column :sections, :building
    add_column :sections, :enrollment_status, :integer
    remove_column :sections, :start_time
    remove_column :sections, :end_time
    remove_column :sections, :days
    add_column :sections, :subject_id, :integer
    rename_column :sections, :semester_slot, :part_of_term
    remove_column :sections, :instructor
    add_column :sections, :semester_id, :integer
    add_column :sections, :text, :string
    add_column :sections, :special_approval, :string
  end

  def down
    remove_column :sections, :location_id
    add_column :sections, :room, :int
    add_column :sections, :building, :string
    remove_column :sections, :enrollment_status
    add_column :sections, :start_time, :time
    add_column :sections, :end_time, :time
    add_column :sections, :days, :string
    remove_column :sections, :subject_id
    rename_column :sections, :part_of_term, :semester_slot
    add_column :sections, :instructor, :string
    remove_column :sections, :semester_id
    remove_column :sections, :text
    remove_column :sections, :special_approval
  end
end
