class RenameTableAgain < ActiveRecord::Migration
  def up
    rename_table :geneds_attribs, :attribs_geneds
  end

  def down
  end
end
