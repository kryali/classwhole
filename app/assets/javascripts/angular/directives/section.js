angular.module('directives').directive("section", function() {
  return domReady(function($scope, element, attrs) {

    function startDrag() {
      $scope.$emit('startDrag');
    }

    function endDrag() {
      $scope.$emit('endDrag');
    }

    var options = {
      containment: '#content',
      //snap:        '.ui-droppable',
      //snapMode:    'inner',
      //snapTolerance: 4,
      start:       startDrag,
      stop:        endDrag,
      revert:      true,
      revertDuration: 200,
      scope:        'section_hint',
      zIndex:       10,
    };
    var sectionElement = $(element);
    Schedule.layoutSection(sectionElement, $scope.section,
      $scope.schedule.hourRange[0]);
    sectionElement.draggable(options).data("id", $scope.section.id);
  });
})

angular.module('directives').directive("hint", ['$parse', function($parse) {
  return domReady(function($scope, element, attrs) {
    var dropFn = $parse(attrs.drop);

    function drop(event, ui) {
      REJECT_EVENTS = false;
      $scope.$apply(function() {
        dropFn($scope, {newSection: $scope.section, oldId: $(ui.draggable).data("id")})
      });
    }

    var options = {
      accept:      '.ui-draggable',
      hoverClass:  'hover',
      drop:        drop,
      scope:       'section_hint',
    };
    var sectionElement = $(element);
    Schedule.layoutSection(sectionElement, $scope.section,
      $scope.schedule.hourRange[0]);
    sectionElement.droppable(options);
    sectionElement.removeClass("out");
  });
}]);
