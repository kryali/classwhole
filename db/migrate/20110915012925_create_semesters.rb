class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.string     "year"
      t.string     "season"
      t.references :subjects
      t.timestamps
    end
  end
end
