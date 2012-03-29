class SectionAddConfigurationIdColumn < ActiveRecord::Migration
  def up
    add_column :sections, :configuration_id, :integer
  end

  def down
    remove_column :sections, :configuration_id
  end
end
