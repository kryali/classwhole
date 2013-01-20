class FuckConfigurationsGroupsAreCooler < ActiveRecord::Migration
  def change 
    rename_table :configurations, :groups
    rename_column :sections, :configuration_id, :group_id
    add_index :sections, :group_id
  end
end
