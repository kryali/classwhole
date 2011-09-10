class AddUserIdColumnToFriendships < ActiveRecord::Migration
  def change
    add_column :friendships, :user_id, :integer
  end
end
