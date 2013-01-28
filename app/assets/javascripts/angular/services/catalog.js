// 
// Client side cache for course data
//

function Catalog($http) {
  this.$http = $http;
  this.cache = {courses: {}, sections: {}, groups: {}};
}


Catalog.prototype.loadCourses = function(ids) {
  var self = this;
  this.$http.post("/catalog/course", {ids: ids}).success(function(data) {
    for(var i in data) {
      self.saveCourse(data[i]);
    }
  });
}

Catalog.prototype.getCourse = function(id, callback) {
  if (this.cache.courses[id]) return this.cache.courses[id];

  var self = this;
  this.$http.post("/catalog/course", {id: id}).success(function(data) {
    self.saveCourse(data);
    if (callback) callback(self.cache.courses[id]);
  });
}

Catalog.prototype.getSection = function(id, callback) {
  if (this.cache.sections[id]) return this.cache.sections[id];

  var self = this;
  this.$http.post("/catalog/section", {id: id}).success(function(data) {
    self.saveSection(data);
    if (callback) callback(self.cache.sections[id]);
  });
}

Catalog.prototype.saveCourse = function(course) {
  this.cache.courses[course.id] = course;
  var size = course.sections.length;
  for (var i = 0; i < size; i++) {
    this.saveSection(course.sections[i]);
  }
}

Catalog.prototype.saveSection = function(section) {
  if (!this.cache.sections[section.id]) {
    this.addToGroups(section);
  }
  this.cache.sections[section.id] = section;
}

Catalog.prototype.addToGroups = function(section) {
  assertObject(this.cache.groups, section.group.id);
  assertObject(this.cache.groups[section.group.id], section.group.key);
  assertArray(this.cache.groups[section.group.id][section.group.key], section.type);
  this.cache.groups[section.group.id][section.group.key][section.type].push(section);
}

function assertObject(obj, key) {
  if (!obj[key]) {
    obj[key] = {};
  }
  return obj[key];
}

function assertArray(obj, key) {
  if (!obj[key]) {
    obj[key] = [];
  }
  return obj[key];
}

angular.module('services').service('Catalog', ['$http', Catalog]);
