class CreateAttributes < ActiveRecord::Migration
  def up
    create_table :attributes do |t|
      t.string :code
      t.string :description
    end
  end

  def down
    drop_table :attributes
  end
end
