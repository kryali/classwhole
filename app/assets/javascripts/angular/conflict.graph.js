'use strict';

var ConflictGraph = function ConflictGraph(ScheduleIter) {
  this.iter = ScheduleIter;
}

angular.module('services').service('ConflictGraph', ['ScheduleIter', ConflictGraph]);

ConflictGraph.prototype.apply = function(sections) {
  for(var i = 0; i < sections.length; i++) {
    this.findConflicts(sections, sections[i]);
  }
  return sections; 
}

ConflictGraph.prototype.findConflicts = function(sections, section) {
  section.conflicts = [];
  for(var i = 0; i < sections.length; i++) {
    if (sections[i].id != section.id && Helper.section_conflicts(section, sections[i])) {
      section.conflicts.push(sections[i].id);
    }
  }
}

ConflictGraph.prototype.removeConflicts = function(schedule, sectionOptions) {
  var options = Utils.copyArray(sectionOptions);
  var to_remove = [];
  this.iter.eachSection(schedule, function(section) {
    to_remove = [];
    for (var i = 0; i < options.length; i++) {
      if(Helper.section_conflicts(section, options[i])) {
        to_remove.push(i);
      }
    }

    for (var i = to_remove.length - 1; i >= 0; i--) {
      options.splice(to_remove[i], 1);
      to_remove.push(i);
    }
  });
  return options;
}

var Helper = {
  section_conflicts: function(sectiona, sectionb) {
    for(var i = 0; i < sectiona.meetings.length; i++) {
      for(var j = 0; j < sectionb.meetings.length; j++) {
        if (Helper.meeting_conflicts(sectiona.meetings[i], sectionb.meetings[j])) {
          return true;
        }
      }
    }

    return false;
  },

  meeting_conflicts: function(meetinga, meetingb) {
    if (!meetinga.start_time || !meetingb.start_time) {
      return false;
    } else {
      var occurs_same_day = meetinga.days.match(new RegExp("[" + meetingb.days + "]"));
      if (!occurs_same_day) return false;

      return Helper.overlaps(meetinga, meetingb) || Helper.overlaps(meetingb, meetinga);
    }
  },

  overlaps: function(meetinga, meetingb) {
    return (meetinga.start_time.value >= meetingb.start_time.value) 
        && (meetinga.start_time.value <= meetingb.end_time.value);
  },
};

