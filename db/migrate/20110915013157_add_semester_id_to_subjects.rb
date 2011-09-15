class AddSemesterIdToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :semester_id, :integer
  end
end
