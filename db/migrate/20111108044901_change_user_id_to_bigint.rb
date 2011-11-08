class ChangeUserIdToBigint < ActiveRecord::Migration
  def up
    change_column :users, :id, :integer, :limit => 8
    change_column :courses, :user_id, :integer, :limit => 8
  end

  def down
  end
end
