from django.db import models

class Courses(models.Model):
	courseNumber = models.IntegerField()
	subjectId = models.IntegerField()
	hours = models.CharField(max_length=200)
	description = models.CharField()
	title = models.CharField(max_length=200)
	subjectCode = models.CharField(max_length=200)
#  create_table "courses", :force => true do |t| 
#    t.integer  "courseNumber"
#    t.string   "hours"
#    t.text     "description"
#    t.string   "title"
#    t.string   "subjectCode"
#    t.integer  "subjectId"
#    t.integer  "major_id"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end 

class Majors(models.Model):
	webSiteAddress = models.CharField(max_length=200)
	address2 = models.CharField(max_length=200)
	contact = models.CharField(max_length=200)
	contactTitle = models.CharField(max_length=200)
	subjectCode = models.CharField(max_length=200)
	unitName = models.CharField(max_length=200)
	phone = models.CharField(max_length=15)
#  create_table "majors", :force => true do |t| 
#    t.string   "webSiteAddress"
#    t.text     "address2"
#    t.string   "contact"
#    t.string   "contactTitle"
#    t.text     "subjectDescription"
#    t.string   "subjectCode"
#    t.string   "unitName"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.string   "phone"
#  end 

class Sections(models.Model):
	room = models.IntegerField()
	referenceNumber = models.IntegerField()
	root = models.CharField()
	type = models.CharField(max_length=200)
	instructor = models.CharField(max_length=200)
	days = models.CharField(max_length=200)
	building = models.CharField(max_length=200)
	sectionId = models.CharField(max_length=200)
	startTime = models.DateTimeField()
	endTime = models.DateTimeField()

 # create_table "sections", :force => true do |t|
 #    t.integer  "room"
 #    t.integer  "referenceNumber"
 #    t.text     "notes"
 #    t.string   "type"
 #    t.string   "instructor"
 #    t.string   "days"
 #    t.time     "startTime"
 #    t.time     "endTime"
 #    t.string   "building"
 #    t.integer  "course_id"
 #    t.string   "sectionId"
 #  end
