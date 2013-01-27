var Schedule = function Schedule(SchedulerService, ColorList) {
  this.scheduler = SchedulerService;
  this.colors = ColorList;
  this.courses = [];
  this.flatSections = [];
  this.hourRange = [];
  this.showHint = {};
  this.busy = false;
}

angular.module('services').service('Schedule', ['SchedulerService', 'ColorList', Schedule]);

Schedule.prototype.setUserId = function(userId) {
  this.userId = userId;
}

Schedule.prototype.enableModify = function(canModify) {
  this.canModify = canModify;
}

Schedule.prototype.setSchedule = function(newSchedule, hourRange) {
  this.courses = newSchedule;
  this.hourRange = hourRange;
  this.flatSchedule = flattenSchedule(newSchedule);
  this.showHint = {};
}

Schedule.prototype.enumerateRange = function() {
  var hourArray = [];
  for(var i = this.hourRange[0]; i < this.hourRange[1]; i++) {
    hourArray.push(i);
  }
  return hourArray;
}

Schedule.prototype.removeCourse = function(courseId) {
  var self = this;
  for (var i = 0; i < this.courses.length; i++) {
    if (this.courses[i].id == courseId) {
      this.courses.splice(i, 1);
      this.flatSchedule = flattenSchedule(this.courses);
      break;
    }
  }

  this.scheduling = true;
  this.scheduler.removeCourse(courseId, function(data) {
    self.scheduling = false;
    self.colors.remove(courseId);
  });
}

Schedule.prototype.addCourse = function(courseId) {
  console.log("THIS WORKED", courseId);
  this.scheduling = true;
  var self = this;
  this.scheduler.addCourse(courseId, function(data) {
    self.scheduling = false;
    if (data.success) {
      self.update();
    } else {
      pop_alert(data.status, data.message);
    }
  });
}

Schedule.prototype.replaceSection = function(oldSectionId, newSection) {
  if (this.stale || !this.canModify) return;

  this.stale = true;
  var self = this;
  this.scheduler.replaceSection(oldSectionId, newSection.id, function() {
    self.stale = false;
  });

  this.hints = [];
  var found = false;
  for (var i = 0; i < this.courses.length; i++) {
    var sections = this.courses[i].sections;
    for (var j = 0; j < sections.length; j++) {
      if (sections[j].id == oldSectionId) {
        this.courses[i].sections.splice(j, 1);
        this.courses[i].sections.push(newSection);
        found = true;
        break;
      }
    }
    if (found) break;
  }
  this.flatSchedule = flattenSchedule(this.courses);
}

Schedule.prototype.hideHints = function(sectionId, element) {
  this.showHint[sectionId] = false;
  this.hints = [];
}

Schedule.prototype.showHints = function(sectionId, element) {
  if (this.stale || !this.canModify) return;
  var self = this;
  this.showHint[sectionId] = true;
  this.scheduler.getHints(sectionId, function(data) {
    if (self.showHint[sectionId]) {
      if (data.success) {
        self.hints = flattenHints(data.section_hints);
      } else {
        var tooltip = new Tooltip("scheduler/_section_message", {message: data.message}); 
        tooltip.putAbove(element, 10);
      }
    }
  });
}

Schedule.prototype.getSections = function() {
  return this.flatSchedule;
}

Schedule.prototype.isEmpty = function() {
  return this.courses.length == 0;
}

Schedule.prototype.update = function() {
  var self = this;
  var data = {id: this.userId};
  this.scheduler.get(data, function(data) {
    self.scheduling = false;
    self.setSchedule(data.schedule, data.hour_range);
  });
}

Schedule.prototype.color = function(id) {
  return "color-" + this.colors.get(id);
}

/*======================================
      Helper methods
 *====================================*/

function flattenSchedule(schedule) {
  var sections = []
  eachMeeting(schedule, function(meeting, section, course) {
    if (meeting.days == null) return;
    var days = meeting.days.split("");
    for (var i = 0; i < days.length; i++) {
      var sectionCopy = Utils.deepCopy(section);
      sectionCopy.day = days[i];
      sectionCopy.duration = meeting.duration;
      sectionCopy.start_time = meeting.start_time;
      sectionCopy.end_time = meeting.end_time;
      sectionCopy.course = course;
      sectionCopy.course_id = section.course_id;
      sections.push(sectionCopy);
    }
  });
  return sections;
}; 

function eachSection(courses, callback) {
  for (var i = 0; i < courses.length; i++) {
    for (var j = 0; j < courses[i].sections.length; j++) {
      callback(courses[i].sections[j], courses[i]);
    }
  }
}

function eachMeeting(courses, callback) {
  eachSection(courses, function(section, course) {
    for (var i = 0; i < section.meetings.length; i++) {
      callback(section.meetings[i], section, course);
    }
  });
}

function flattenHints(sections) {
  var flatHints = []
  if (sections) {
    for (var k = 0; k < sections.length; k++) {
      var section = sections[k];
      for (var i = 0; i < section.meetings.length; i++) {
        var meeting = section.meetings[i];
        if (meeting.days == null) break;
        var days = meeting.days.split("");
        for (var j = 0; j < days.length; j++) {
          var sectionCopy = Utils.deepCopy(section);
          sectionCopy.day = days[j];
          sectionCopy.duration = meeting.duration;
          sectionCopy.start_time = meeting.start_time;
          sectionCopy.end_time = meeting.end_time;
          sectionCopy.course_id = section.course_id;
          flatHints.push(sectionCopy);
        }
      }
    }
  }
  return flatHints;
}
