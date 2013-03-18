var Schedule = function Schedule(Scheduler, ColorList, Catalog, ConflictGraph, ScheduleIter) {
  this.scheduler = Scheduler;
  this.catalog = Catalog;
  catalog = Catalog;
  this.colors = ColorList;
  this.courses = [];
  this.flatSections = [];
  this.hourRange = [];
  this.showHint = {};
  this.busy = false;
  this.iter = ScheduleIter;
  this.conflictGraph = ConflictGraph;
}

angular.module('services').service('Schedule', ['Scheduler', 'ColorList', 'Catalog', 'ConflictGraph', 'ScheduleIter', Schedule]);

Schedule.prototype.setUserId = function(userId) {
  this.userId = userId;
}

Schedule.prototype.enableModify = function(canModify) {
  this.canModify = canModify;
}

Schedule.prototype.setSchedule = function(newSchedule, hourRange) {
  this.courses = newSchedule;
  this.hourRange = hourRange;
  this.flatSchedule = this.flattenSchedule(newSchedule);
  this.showHint = {};
  console.log(this.courses);

  // Preload course data
  var ids = [];
  for (var i = 0; i < this.courses.length; i++) {
    ids.push(this.courses[i].id);
  }
  this.catalog.loadCourses(ids);
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
      this.flatSchedule = this.flattenSchedule(this.courses);
      break;
    }
  }

  this.loadingMessage = "removing...";
  this.scheduler.removeCourse(courseId, function(data) {
    self.loadingMessage = false;
    self.colors.remove(courseId);
  });
}

Schedule.prototype.addCourse = function(courseId) {
  this.loadingMessage = "scheduling...";
  var self = this;
  this.scheduler.addCourse(courseId, function(data) {
    self.loadingMessage = false;
    if (data.success) {
      self.update();
    } else {
      pop_alert(data.status, data.message);
    }
  });
}

Schedule.prototype.changeGroup = function(courseId, groupKey) {
  console.log("changing this stupis group");
  this.loadingMessage = "scheduling...";
  var self = this;
  this.scheduler.changeGroup(courseId, groupKey, function(data) {
    self.loadingMessage = false;
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
  this.flatSchedule = this.flattenSchedule(this.courses);
}

Schedule.prototype.hideHints = function(sectionId, element) {
  this.showHint[sectionId] = false;
  this.hints = [];
}

Schedule.prototype.showHints = function(sectionId, element) {
  if (this.stale || !this.canModify) return;
  var self = this;
  this.showHint[sectionId] = true;
  self.catalog.getSectionOptions(sectionId, function(allSectionOptions) {
    var finalOptions = self.conflictGraph.removeConflicts(self.courses, allSectionOptions);
    if (finalOptions.length > 0 ) {
      finalOptions = self.conflictGraph.apply(finalOptions);
      self.hints = flattenHints(finalOptions);
    } else {
      var tooltip = new Tooltip("scheduler/_section_message", {message: "No alternate sections"}); 
      tooltip.putAbove(element, 10);
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
    console.log(data);
    self.setSchedule(data.schedule, data.hour_range);
  });
}

Schedule.prototype.color = function(id) {
  return "color-" + this.colors.get(id);
}

Schedule.prototype.flattenSchedule = function(schedule) {
  var sections = []
  this.iter.eachMeeting(schedule, function(meeting, section, course) {
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


/*======================================
      Helper methods
 *====================================*/

function print_duration(meeting) {
  return meeting.hour + "-" + meeting.min;
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
