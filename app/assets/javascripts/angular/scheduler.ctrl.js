
// What it does
// - Adding, removing, and modifying courses
// - showing landing page / active schedule

function SchedulerCtrl($scope, $http, SchedulerService, ColorList, Schedule) {

  /****************************************
    initialization
  ****************************************/

  $scope.schedule = Schedule;
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
    return Schedule.isEmpty();
  }

  $scope.showActiveSchedule = function() {
    return !Schedule.isEmpty();
  }

  $scope.replaceSection = function(oldSectionId, newSection) {
    Schedule.replaceSection(oldSectionId, newSection);
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
    if (!$scope.canModify) return;
    Schedule.showHints(sectionId, element);
  };

  $scope.hideHints = function(sectionId) {
    Schedule.hideHints(sectionId);
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

  /* Need this to turn off hints when a drag stops */
  $scope.$on('endDrag', function() {
    $scope.$apply(function() {
      Schedule.hideHints();
    });
  });

  $scope.days = function() {
    return ['Mon', 'Tue', 'Wed', 'Thur', 'Fri'];
  }

  $scope.color = function(id) {
    return "color-" + $scope.colors.get(id);
  }

  function save(data) {
    Schedule.setSchedule(data["schedule"], data["hour_range"]);
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
  
  function to12hr(hour) {
    return hour == 12 ? "12" : hour % 12;
  }
}

// need to do this for minification. Javascript is the world's purest evil.
SchedulerCtrl.$inject = ['$scope', '$http', 'SchedulerService', 'ColorList', 'Schedule'];
