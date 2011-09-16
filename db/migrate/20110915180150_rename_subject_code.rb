class RenameSubjectCode < ActiveRecord::Migration
  def up
    change_table :subjects do |t|
      t.rename :subjectCode, :code
      t.rename :webSiteAddress, :web_site_address
      t.rename :contactTitle, :contact_title
      t.rename :subjectDescription, :subject_description
      t.rename :unitName, :unit_name
    end
    change_table :courses do |t|
      t.rename :courseNumber, :number
      t.rename :subjectCode, :subject_code
      t.rename :subjectId, :subject_id
    end
    change_table :sections do |t|
      t.rename :referenceNumber, :reference_number
      t.rename :startTime, :start_time
      t.rename :endTime, :end_time
      t.rename :sectionId, :code
    end
  end

  def down
  end
end
