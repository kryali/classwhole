class ChangeTypeHours < ActiveRecord::Migration
  def up
    change_table :courses do |t|
      t.change :hours, :integer
    end
  end

  def down
    change_table :courses do |t|
      t.change :hours, :string
    end
  end
end
