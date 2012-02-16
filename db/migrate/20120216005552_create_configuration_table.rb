class CreateConfigurationTable < ActiveRecord::Migration
  def up
    create_table :configurations do |t|
      t.string :key
    end
  end

  def down
    drop_table :configurations
  end
end
