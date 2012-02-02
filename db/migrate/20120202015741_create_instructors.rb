class CreateInstructors < ActiveRecord::Migration
  def up
    create_table :instructors do |t|
      t.string :full_name
      t.string :first_name
      t.string :last_name
      t.float :quality_rating
      t.float :easiness_rating
      t.float :clarity_rating
      t.float :helpfulness_rating
      t.string :rmp_url
      t.string :url
    end
  end

  def down
    drop_table :instructors
  end
end
