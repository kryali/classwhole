function Scheduler($http) {
  this.$http = $http;
}

Scheduler.prototype.get = function(data, callback) {
  this.$http.post("/scheduler/schedule", data).success(safe(callback));
}

Scheduler.prototype.addCourse = function(courseId, callback) {
  this.$http.post("/scheduler/courses/new/", {id:courseId}).success(safe(callback));
}

Scheduler.prototype.removeCourse = function(courseId, callback) {
  this.$http.post("/scheduler/courses/destroy/", {id:courseId}).success(safe(callback));
}

Scheduler.prototype.replaceSection = function(oldSectionId, newSectionId, callback) {
  this.$http.post("/scheduler/schedule/replace", {add_id: newSectionId, del_id: oldSectionId}).success(safe(callback));
}

Scheduler.prototype.changeGroup = function(courseId, groupKey, callback) {
  this.$http.post("/scheduler/group/change", {course_id: courseId, new_group_key: groupKey}).success(safe(callback));
}

function safe(callback) {
  return function(data) {
    if (callback) callback(data);
  }
}

angular.module('services').service('Scheduler', ['$http', Scheduler]);
