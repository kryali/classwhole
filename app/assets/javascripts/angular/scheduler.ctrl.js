function SchedulerCtrl($scope, $http, SchedulerService, ColorList) {

  $scope.colors = ColorList;
  console.log("SchedulerCtrl scope: " + $scope.$id);
  save(initial_schedule);

  /****************************************
    api methods
  ****************************************/
  $scope.removeCourse = function(courseId) {
    SchedulerService.removeCourse(courseId, function(data) {
      ColorList.remove(courseId);
      console.log(data);
      update();
    });
  };

  $scope.addCourse = function(courseId) {
    SchedulerService.addCourse(courseId, function(data) {
      console.log(data);
      update();
    });
  };

  /****************************************
    helper methods
  ****************************************/
  $scope.print_hour = function(hour) {
    return hour % 2 == 0 ? to12hr(hour) : "";
  }
  
  $scope.print_instructor = function(professor) {
    return professor ? professor : "TBD";
  };

  $scope.flattenSchedule = function(schedule) {
    sections = []
    eachMeeting(schedule, function(meeting, section, course) {
      if (meeting.days == null) return;
      var days = meeting.days.split("");
      for (var l = 0; l < days.length; l++) {
        var sectionCopy = Utils.deepCopy(section);
        sectionCopy.day = days[l];
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
    $scope.hourRange = enumerateHours(data["hour_range"]);
  }

  function update() {
    SchedulerService.get(function(data) {
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
