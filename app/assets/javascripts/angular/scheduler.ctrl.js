function SchedulerCtrl($scope, $http, SchedulerService, ColorList) {

  $scope.colors = ColorList;
  $scope.showHint = {}
  save(initial_schedule);

  /****************************************
    api methods
  ****************************************/
  $scope.removeCourse = function(courseId) {
    SchedulerService.removeCourse(courseId, function(data) {
      for (var i = 0; i < $scope.schedule.length; i++) {
        if ($scope.schedule[i].id == courseId) {
          $scope.schedule.splice(i, 1);
          $scope.flatSchedule = flattenSchedule($scope.schedule);
          break;
        } 
      }
      ColorList.remove(courseId);
    });
  };

  $scope.addCourse = function(courseId) {
    $scope.scheduling = true;
    SchedulerService.addCourse(courseId, function(data) {
      if (data.success) {
        update($scope);
      } else {
        $scope.scheduling = false;
        pop_alert(data.status, data.message);
      }
    });
  };

  $scope.showHints = function(section_id) {
    $scope.showHint[section_id] = true;
    SchedulerService.getHints(section_id, function(data) {
      if (data.success && $scope.showHint[section_id]) {
        $scope.scheduleHints = flattenHints(data["section_hints"]);
      }
      //console.log(data);
    });
  };

  $scope.hideHints = function(section_id) {
    $scope.showHint[section_id] = false;
    $scope.scheduleHints = [];
  }

  /****************************************
    helper methods
  ****************************************/
  $scope.print_hour = function(hour) {
    return hour % 2 == 0 ? to12hr(hour) : "";
  }
  
  $scope.print_instructor = function(professor) {
    return professor ? professor : "TBD";
  };

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
            flatHints.push(sectionCopy);
          }
        }
      }
    }
    return flatHints;
  }

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
        sections.push(sectionCopy);
      }
    });
    return sections;
  }; 

  $scope.days = function() {
    return ['Mon', 'Tue', 'Wed', 'Thur', 'Fri'];
  }

  $scope.color = function(id) {
    return "color-" + $scope.colors.get(id);
  }

  function enumerateHours(hourRange) {
    hourArray = [];
    for(var i = hourRange[0]; i < hourRange[1]; i++) {
      hourArray.push(i);
    }
    return hourArray;
  }

  function save(data) {
    $scope.schedule = data["schedule"];
    $scope.flatSchedule = flattenSchedule(data["schedule"]);
    $scope.hourRange = enumerateHours(data["hour_range"]);
  }

  function update($scope) {
    SchedulerService.get(function(data) {
      $scope.scheduling = false;
      save(data);
    });
  }

  function eachMeeting(courses, callback) {
    for (var i = 0; i < courses.length; i++) {
      for (var j = 0; j < courses[i].sections.length; j++) {
        var section = courses[i].sections[j];
        for (var k = 0; k < section.meetings.length; k++) {
          callback(section.meetings[k], section, courses[i]);
        }
      }
    }
  }
  
  function to12hr(hour) {
    return hour == 12 ? "12" : hour % 12;
  }
}
