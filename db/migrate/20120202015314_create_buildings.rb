class CreateBuildings < ActiveRecord::Migration
  def up
    create_table :locations do |t|
      t.string :name
      t.string :short_name
      t.float :latitude
      t.float :longitude
      t.string :address
    end
  end

  def down
    drop_table :locations
  end
end
