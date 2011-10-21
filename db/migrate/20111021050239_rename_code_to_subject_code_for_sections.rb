class RenameCodeToSubjectCodeForSections < ActiveRecord::Migration
  def change
    rename_column :sections, :course_code, :course_subject_code
  end
end
