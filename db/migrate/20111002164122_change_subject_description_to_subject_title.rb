class ChangeSubjectDescriptionToSubjectTitle < ActiveRecord::Migration
  def change
    rename_column :subjects, :subject_description, :title
  end
end
