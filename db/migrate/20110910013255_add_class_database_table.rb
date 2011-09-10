class AddClassDatabaseTable < ActiveRecord::Migration
  def up
      create_table "courses", :force => true do |t|
        t.integer  "courseNumber"
        t.string   "hours"
        t.text     "description"
        t.string   "title"
        t.string   "subjectCode"
        t.integer  "subjectId"
        t.integer  "major_id"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      create_table "subjects", :force => true do |t|
        t.string   "webSiteAddress"
        t.text     "address2"
        t.string   "contact"
        t.string   "contactTitle"
        t.text     "subjectDescription"
        t.string   "subjectCode"
        t.string   "unitName"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "phone"
      end

      create_table "sections", :force => true do |t|
        t.integer  "room"
        t.integer  "referenceNumber"
        t.text     "notes"
        t.string   "type"
        t.string   "instructor"
        t.string   "days"
        t.time     "startTime"
        t.time     "endTime"
        t.string   "building"
        t.integer  "course_id"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "sectionId"
      end
  end

  def down
    drop_table "courses"
    drop_table "subjects"
    drop_table "sections"
  end
end
