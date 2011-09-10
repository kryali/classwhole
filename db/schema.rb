# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110910020523) do

  create_table "courses", :force => true do |t|
    t.integer  "courseNumber"
    t.string   "hours"
    t.text     "description"
    t.string   "title"
    t.string   "subjectCode"
    t.integer  "subjectId"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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

end
