angular.module('services', []).service('SchedulerService', SchedulerService);

function SchedulerService($http) {
  this.$http = $http;
}

SchedulerService.prototype.get = function(callback) {
  this.$http.post("/scheduler/schedule").success(callback);
}

SchedulerService.prototype.addCourse = function(courseId, callback) {
  this.$http.post("/scheduler/courses/new/", {id:courseId}).success(callback);
}

SchedulerService.prototype.removeCourse = function(courseId, callback) {
  this.$http.post("/scheduler/courses/destroy/", {id:courseId}).success(callback);
}
