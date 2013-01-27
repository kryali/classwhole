angular.module('services').service('SchedulerService', ['$http', SchedulerService]);

function SchedulerService($http) {
  this.$http = $http;
}

SchedulerService.prototype.get = function(data, callback) {
  this.$http.post("/scheduler/schedule", data).success(safe(callback));
}

SchedulerService.prototype.addCourse = function(courseId, callback) {
  this.$http.post("/scheduler/courses/new/", {id:courseId}).success(safe(callback));
}

SchedulerService.prototype.removeCourse = function(courseId, callback) {
  this.$http.post("/scheduler/courses/destroy/", {id:courseId}).success(safe(callback));
}

SchedulerService.prototype.getHints = function(sectionId, callback) {
  this.$http.post("/scheduler/section/hints/", {id: sectionId}).success(safe(callback));
}

SchedulerService.prototype.replaceSection = function(oldSectionId, newSectionId, callback) {
  this.$http.post("/scheduler/schedule/replace", {add_id: newSectionId, del_id: oldSectionId}).success(safe(callback));
}

function safe(callback) {
  return function(data) {
    if (callback) callback(data);
  }
}
