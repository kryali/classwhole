class RenameTypeInMeeting < ActiveRecord::Migration
  def up
    rename_column :meetings, :type, :class_type
  end

  def down

  end
end
