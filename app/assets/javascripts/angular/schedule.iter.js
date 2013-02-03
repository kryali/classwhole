var ScheduleIter = function() {
  return {
    eachSection: function(courses, callback) {
      for (var i = 0; i < courses.length; i++) {
        for (var j = 0; j < courses[i].sections.length; j++) {
          callback(courses[i].sections[j], courses[i]);
        }
      }
    },

    eachMeeting: function(courses, callback) {
      this.eachSection(courses, function(section, course) {
        for (var i = 0; i < section.meetings.length; i++) {
          callback(section.meetings[i], section, course);
        }
      });
    }
  }
}

angular.module('services').factory('ScheduleIter', ScheduleIter);
