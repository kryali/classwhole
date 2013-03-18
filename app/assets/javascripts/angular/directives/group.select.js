angular.module('directives').directive('groupSelect', ['$parse', function($parse) {
  return domReady(function($scope, iElement, attrs) {
    var fn = $parse(attrs.onSelect);

    /** Fucking piece of shit angular can't bind to a select element change so do this fucking voodoo bullshit rage so hard */
    var iParent = $(iElement).parent();
    if (!iParent.data("change-bound")) {
      iParent.change(function() {
        var data = iParent.val().split(",");
        var courseId = data[0];
        var key = data[1];
        $scope.$apply(function($scope) {
          fn($scope, {courseId: courseId, groupKey: key});
        });
      });
      iParent.data("change-bound", true);
    }
  });
}]);
