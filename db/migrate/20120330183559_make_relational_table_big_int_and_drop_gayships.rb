class MakeRelationalTableBigIntAndDropGayships < ActiveRecord::Migration
  def change
    change_column :courses_users, :user_id, :integer, :limit => 8
    drop_table :friendships
  end
end
