class CreateGeneds < ActiveRecord::Migration
  def up
    create_table :geneds do |t|
      t.string :category_id
      t.string :description
    end
  end

  def down
    drop_table :geneds
  end
end
