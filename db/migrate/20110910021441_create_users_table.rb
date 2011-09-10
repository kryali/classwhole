class CreateUsersTable < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string   "fb_id"
      t.string   "fb_token"
      t.string   "g_token"
      t.string   "email"
    end
  end

  def down
    drop_table :users
  end
end
