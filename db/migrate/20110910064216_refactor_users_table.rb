class RefactorUsersTable < ActiveRecord::Migration
  def up
    add_column :users, :name, :string
    add_column :users, :first_name, :string
		add_column :users, :last_name, :string
		add_column :users, :link, :string
		add_column :users, :gender, :string
  end
  def down
    remove_column :users, :name
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :link
		remove_column :users, :gender
  end
end
