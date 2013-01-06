angular.module('directives').directive("truncate", function() {
  return domReady(function($scope, iElement, attrs) {
    Utils.truncate(iElement, parseInt(attrs.truncate));
  });
})

