function CourseListCtrl($scope, $http) {
  $scope.courses = initial_schedule;
  $http.get("courses").success(function(data) {
    $scope.courses = data;
  });

  $scope.print_instructor = function(professor) {
    return professor ? professor : "TBD";
  }
}
