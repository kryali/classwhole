angular.module('directives').directive('mousehover', function($parse) {

  return {
    link: function($scope, iElement, attrs) {
      var element = $(iElement);
      var fn = $parse(attrs.mousehover);
      var defMouseLeave = $parse(attrs.mouseleave);
      var timeout;

      $scope.$on('startDrag', function() {
        element.unbind("mouseenter", mouseEnter);
        element.unbind("mouseleave", mouseLeave);
      });

      $scope.$on('endDrag', function() {
        element.bind("mouseenter", mouseEnter);
        element.bind("mouseleave", mouseLeave);
         // Manually firing mouse leave event since it doesn't get triggered when dragging stops.
        mouseLeave();
      });

      function mouseEnter(event) {
        timeout = setTimeout(function() {
        }, 70); // threshold for mouse hover

        $scope.$apply(function() {
          fn($scope, {$element: element});
        });
      }

      function mouseLeave(event) {
        clearTimeout(timeout);
        if (defMouseLeave) {
          $scope.$apply(function(event) {
            defMouseLeave($scope, {$event: event});
          }); 
        }
      };

      element.bind("mouseenter", mouseEnter);
      element.bind("mouseleave", mouseLeave);
    }
  }
});
