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

ActiveRecord::Schema.define(:version => 20120319012833) do

  create_table "attribs", :force => true do |t|
    t.string "code"
    t.string "description"
  end

  create_table "attribs_geneds", :id => false, :force => true do |t|
    t.integer "gened_id"
    t.integer "attrib_id"
  end

  create_table "buildings", :force => true do |t|
    t.string "name"
    t.string "short_name"
    t.float  "latitude"
    t.float  "longitude"
    t.string "address"
  end

  create_table "configurations", :force => true do |t|
    t.string  "key"
    t.integer "course_id"
  end

  create_table "courses", :force => true do |t|
    t.integer  "number"
    t.integer  "credit_hours",         :limit => 255
    t.text     "description"
    t.string   "title"
    t.string   "subject_code"
    t.integer  "subjectId"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "section_information"
    t.text     "schedule_information"
  end

  create_table "courses_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "course_id"
  end

  create_table "friendships", :force => true do |t|
    t.integer "friend_id"
    t.integer "user_id"
  end

  create_table "geneds", :force => true do |t|
    t.string "category_id"
    t.string "description"
  end

  create_table "geneds_courses", :id => false, :force => true do |t|
    t.integer "gened_id"
    t.integer "course_id"
  end

  create_table "instructors", :force => true do |t|
    t.string "full_name"
    t.string "first_name"
    t.string "last_name"
    t.float  "quality_rating"
    t.float  "easiness_rating"
    t.float  "clarity_rating"
    t.float  "helpfulness_rating"
    t.string "rmp_url"
    t.string "url"
  end

  create_table "instructors_meetings", :id => false, :force => true do |t|
    t.integer "meeting_id"
    t.integer "instructor_id"
  end

  create_table "meetings", :force => true do |t|
    t.string  "class_type"
    t.time    "start_time"
    t.time    "end_time"
    t.string  "days"
    t.string  "room"
    t.integer "building_id"
    t.integer "section_id"
    t.integer "meeting_number"
  end

  create_table "schools", :force => true do |t|
    t.string "name"
    t.string "short_name"
  end

  create_table "sections", :force => true do |t|
    t.integer  "reference_number"
    t.text     "notes"
    t.string   "section_type"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.string   "course_subject_code"
    t.string   "course_title"
    t.integer  "course_number"
    t.integer  "part_of_term",        :default => 0
    t.integer  "enrollment_status"
    t.integer  "subject_id"
    t.integer  "semester_id"
    t.string   "text"
    t.string   "special_approval"
    t.integer  "configuration_id"
    t.string   "short_code"
  end

  create_table "sections_meetings", :id => false, :force => true do |t|
    t.integer "sections_id"
    t.integer "meetings_id"
  end

  create_table "semesters", :force => true do |t|
    t.string   "year"
    t.string   "season"
    t.integer  "subjects_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
  end

  create_table "subjects", :force => true do |t|
    t.string   "web_site_address"
    t.text     "address2"
    t.string   "contact"
    t.string   "contact_title"
    t.text     "title"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone"
    t.integer  "semester_id"
    t.string   "address1"
  end

  create_table "users", :id => false, :force => true do |t|
    t.integer "id",         :limit => 8
    t.string  "fb_id"
    t.string  "fb_token"
    t.string  "g_token"
    t.string  "email"
    t.string  "name"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "link"
    t.string  "gender"
  end

end
