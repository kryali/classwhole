angular.module('services').service('Catalog', ['$http', Catalog]);

function Catalog($http) {
  this.$http = $http;
  this.cache = {courses: [], sections: []};
}

Catalog.prototype.getCourse = function(id, callback) {
  if (this.cache.courses[id]) return this.cache.courses[id];

  var self = this;
  this.$http.post("/catalog/courses", {id: id}).success(function(data) {
    self.cache.courses[id] = data;
  });
}

Catalog.prototype.getSection = function(id, callback) {
  if (this.cache.sections[id]) return this.cache.courses[id];
  var self = this;
  this.$http.post("/catalog/sections", {id: id}).success(function(data) {
    self.cache.sections[id] = data;
  });
}
