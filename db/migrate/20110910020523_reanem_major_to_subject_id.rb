class ReanemMajorToSubjectId < ActiveRecord::Migration
  def up
    rename_column(:courses, "major_id", "subject_id")
  end

  def down
  end
end
