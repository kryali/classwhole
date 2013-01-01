function CourseListCtrl($scope, $http, SchedulerService) {
  console.log("CourseListCtrl scope: " + $scope.$id);
  
  function update() {
    SchedulerService.get(function(data) {
      console.log(data);
      $scope.courses = data;
    });
  }

  $scope.courses = initial_schedule;

  $scope.print_instructor = function(professor) {
    return professor ? professor : "TBD";
  };

  $scope.removeCourse = function(courseId) {
    SchedulerService.removeCourse(courseId, function(data) {
      console.log(data);
      update();
    });
    console.log(courseId);
  };

  $scope.addCourse = function(courseId) {
    SchedulerService.addCourse(courseId, function(data) {
      console.log(data);
      update();
    });
  }
}
