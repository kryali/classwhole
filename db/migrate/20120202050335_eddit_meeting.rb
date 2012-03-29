class EdditMeeting < ActiveRecord::Migration
  def up
    add_column :meetings, :section_id, :integer
  end

  def down
  end
end
