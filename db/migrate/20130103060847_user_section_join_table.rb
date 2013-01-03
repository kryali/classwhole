class UserSectionJoinTable < ActiveRecord::Migration
  def up
    create_table 'sections_users', :id => false do |t|
      t.column :section_id, :integer
      t.column :user_id, :integer
    end
  end

  def down
    drop_table 'sections_users'
  end
end
