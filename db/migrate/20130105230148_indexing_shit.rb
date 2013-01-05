class IndexingShit < ActiveRecord::Migration
  def change
    add_index :users, :fb_id
    add_index :sections, :reference_number
  end
end
