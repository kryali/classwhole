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

ActiveRecord::Schema.define(:version => 20110901003442) do

  create_table "announcements", :force => true do |t|
    t.string   "atype"
    t.time     "dueTime"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "course_id"
    t.date     "dueDate"
  end

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

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

  create_table "courses_users", :id => false, :force => true do |t|
    t.integer "course_id", :null => false
    t.integer "user_id",   :null => false
  end

  create_table "majors", :force => true do |t|
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

  create_table "notify_prefs", :force => true do |t|
    t.boolean  "email",      :default => false
    t.boolean  "text",       :default => false
    t.boolean  "android",    :default => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rank"
  end

  create_table "responses", :force => true do |t|
    t.text     "content"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_answer",   :default => false
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

  create_table "sections_users", :id => false, :force => true do |t|
    t.integer "section_id", :null => false
    t.integer "user_id",    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "phone"
    t.boolean  "isStudent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "firstname"
    t.string   "lastname"
  end

end
