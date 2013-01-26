
// What it does
// - Adding, removing, and modifying courses
// - showing landing page / active schedule

function SchedulerCtrl($scope, $http, SchedulerService, ColorList) {

  /****************************************
    initialization
  ****************************************/

  $scope.colors = ColorList;
  init(initData); // initData gets set as a global var through the html (show.haml/index.haml)

  function init(data) {
    $scope.showHint = {}
    $scope.id = data.id;
    $scope.canModify = data.canModify;
    save(data.schedule);
  }


  /****************************************
    html template methods
  ****************************************/
    
  $scope.showLandingPage = function() {
    return $scope.schedule.length <= 0;
  }

  $scope.showActiveSchedule = function() {
    return $scope.schedule.length > 0;
  }

  $scope.replaceSection = function(oldSectionId, newSection) {
    $scope.dragging = true;
    $scope.scheduleHints = [];
    replaceSection(oldSectionId, newSection);
    if ($scope.canModify) {
      SchedulerService.replaceSection(oldSectionId, newSection.id, function(data) {
        $scope.dragging = false;
      });
    }
  }

  $scope.removeCourse = function(courseId) {
    $scope.scheduling = true;
    SchedulerService.removeCourse(courseId, function(data) {
      $scope.scheduling = false;
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
        update();
      } else {
        $scope.scheduling = false;
        pop_alert(data.status, data.message);
      }
    });
  };

  $scope.showHints = function(sectionId, element) {
    if (!$scope.canModify || $scope.dragging) return;
    $scope.showHint[sectionId] = true;
    SchedulerService.getHints(sectionId, function(data) {
      if ($scope.showHint[sectionId]) {
        if (data.success) {
          $scope.scheduleHints = flattenHints(data["section_hints"]);
        } else {
          var tooltip = new Tooltip("scheduler/_section_message", {message: data.message}); 
          tooltip.putAbove(element, 10);
        }
      }
    });
  };

  $scope.hideHints = function(sectionId) {
    return;
    if ($scope.dragging) return;
    $scope.showHint[sectionId] = false;
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

  $scope.$on('startDrag', function() {
    $scope.dragging = true;
  });

  $scope.$on('endDrag', function() {
    $scope.dragging = false;
    $scope.$apply(function() {
      $scope.scheduleHints = [];
    });
  });

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

  $scope.days = function() {
    return ['Mon', 'Tue', 'Wed', 'Thur', 'Fri'];
  }

  $scope.color = function(id) {
    return "color-" + $scope.colors.get(id);
  }

  function replaceSection(oldSectionId, newSection) {
    var courses = $scope.schedule;
    var found = false;
    for (var i = 0; i < courses.length; i++) {
      var sections = courses[i].sections;
      for (var j = 0; j < sections.length; j++) {
        if (sections[j].id == oldSectionId) {
          courses[i].sections.splice(j, 1);
          courses[i].sections.push(newSection);
          found = true;
          break;
        }
      }
      if (found) break;
    }
    $scope.flatSchedule = flattenSchedule($scope.schedule);
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

  function update() {
    if ($scope.id) {
      SchedulerService.getId($scope.id, function(data) {
        $scope.scheduling = false;
        save(data);
      });
    } else {
      SchedulerService.get(function(data) {
        $scope.scheduling = false;
        save(data);
      });
    }
  }

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
  
  function to12hr(hour) {
    return hour == 12 ? "12" : hour % 12;
  }
}

// need to do this for minification. Javascript is the world's purest evil.
SchedulerCtrl.$inject = ['$scope', '$http', 'SchedulerService', 'ColorList'];
