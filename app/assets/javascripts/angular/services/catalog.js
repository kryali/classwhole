// 
// Client side cache for course data
//

function Catalog($http) {
  this.$http = $http;
  this.cache = {courses: {}, sections: {}, groups: {}};
}


Catalog.prototype.loadCourses = function(ids) {
  var lookup = [];
  for (var i in ids) {
    if (!this.cache.courses[ids[i]]) {
      lookup.push(ids[i]);
    }
  }
  if (lookup.length > 0) {
    var self = this;
    this.$http.post("/catalog/course", {ids: lookup}).success(function(data) {
      console.log(data);
      for(var i in data) {
        self.saveCourse(data[i]);
      }
    });
  }
}

Catalog.prototype.getCourse = function(id, callback) {
  if (this.cache.courses[id]) {
    callback(this.cache.courses[id]);
    return;
  }

  var self = this;
  this.$http.post("/catalog/course", {id: id}).success(function(data) {
    self.saveCourse(data);
    if (callback) callback(self.cache.courses[id]);
  });
}

Catalog.prototype.getSection = function(id, callback) {
  if (this.cache.sections[id]) {
    callback(this.cache.sections[id]);
    return;
  }

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

Catalog.prototype.getSectionOptions = function(sectionId, callback) {
  var self = this;
  this.getSection(sectionId, function(section) {
    self.getCourse(section.course_id, function(course) {
      callback(self.cache.groups[section.group.id][section.group.key][section.type]);
    });
  });
};

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
