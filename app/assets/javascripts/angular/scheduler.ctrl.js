
// What it does
// - Adding, removing, and modifying courses
// - showing landing page / active schedule

function SchedulerCtrl($scope, $http, Schedule) {

  /****************************************
    initialization
  ****************************************/

  $scope.schedule = Schedule;
  init(initData); // initData gets set as a global var through the html (show.haml/index.haml)

  function init(data) {
    Schedule.setSchedule(data.schedule, data.hour_range);
    Schedule.setUserId(data.id);
    Schedule.enableModify(data.canModify);
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

  function to12hr(hour) {
    return hour == 12 ? "12" : hour % 12;
  }
}

// need to do this for minification. Javascript is the world's purest evil.
SchedulerCtrl.$inject = ['$scope', '$http', 'Schedule'];
