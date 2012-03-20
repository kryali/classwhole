class AddingSectionShortCode < ActiveRecord::Migration
  def up
    add_column :sections, :short_code, :string
  end

  def down
    remove_column :sections, :short_code
  end
end
