class Friendships < ActiveRecord::Migration
  def up
    create_table :friendships do |t|
      t.integer "friend_id"
    end
  end

  def down
    drop_table :friendships
  end
end
