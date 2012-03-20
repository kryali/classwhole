class ChangeShortCodeToShortType < ActiveRecord::Migration
  def up
    rename_column :sections, :short_code, :short_type
  end

  def down
    rename_column :sections, :short_type, :short_code
  end
end
