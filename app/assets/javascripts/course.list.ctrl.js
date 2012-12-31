function CourseListCtrl($scope, $http) {
  $scope.courses = initial_schedule;
  $http.get("/scheduler/courses").success(function(data) {
    $scope.courses = data;
  });

  $scope.print_instructor = function(professor) {
    return professor ? professor : "TBD";
  }

  $scope.truncate = function(word, length) {
    return Utils.truncate(word, length);
  }
}
