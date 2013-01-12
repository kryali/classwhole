angular.module('directives').directive('animate', function() {
  return domReady(function($scope, element, attrs) {
    element.addClass(attrs.animate);
  });
});
