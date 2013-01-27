var REJECT_EVENTS = false;

angular.module('directives').directive('mousehover', ['$parse', function($parse) {

  return {
    link: function($scope, iElement, attrs) {
      var element = $(iElement);
      var fnMouseHover = $parse(attrs.mousehover);
      var fnMouseLeave = $parse(attrs.mouseleave);
      var timeout;

      $scope.$on('startDrag', function() {
        REJECT_EVENTS = true;
      });

      $scope.$on('endDrag', function() {
        REJECT_EVENTS = false;
      });

      function mouseEnter(event) {
        if (REJECT_EVENTS) return;
        timeout = setTimeout(function() {
          $scope.$apply(function() {
            fnMouseHover($scope, {$element: element});
          });
        }, 50); // threshold for mouse hover
      }

      function mouseLeave(event) {
        if (REJECT_EVENTS) return;
        clearTimeout(timeout);
        if (fnMouseLeave) {
          $scope.$apply(function(event) {
            fnMouseLeave($scope, {$event: event});
          }); 
        }
      };

      element.bind("mouseenter", mouseEnter);
      element.bind("mouseleave", mouseLeave);
    }
  }
}]);
