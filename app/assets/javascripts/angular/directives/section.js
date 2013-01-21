angular.module('directives').directive("section", function() {
  return domReady(function($scope, element, attrs) {

    function startDrag() {
      $scope.$emit('startDrag');
    }

    function endDrag() {
      $scope.$emit('endDrag');
    }

    var options = {
      snap:        '.ui-droppable',
      snapMode:    'inner',
      snapTolerance: 20,
      start:       startDrag,
      stop:        endDrag,
      revert:      true,
      revertDuration: 200,
      scope:        'section_hint',
      zIndex:       10,
    };
    var sectionElement = $(element);
    Schedule.layoutSection(sectionElement, $scope.section, $scope.hourRange[0]); 
    sectionElement.draggable(options).data("id", $scope.section.id);
  });
})

angular.module('directives').directive("hint", function() {
  return domReady(function($scope, element, attrs) {

    function drop(event, ui) {
      $scope.$emit('endDrag');
      $scope.$apply(function() {
        $scope.replaceSection($(ui.draggable).data("id"), $scope.section);
      });
    }

    var options = {
      accept:      '.ui-draggable',
      hoverClass:  'hover',
      drop:        drop,
      scope:       'section_hint',
    };
    var sectionElement = $(element);
    Schedule.layoutSection(sectionElement, $scope.section, $scope.hourRange[0]); 
    sectionElement.droppable(options);
    sectionElement.addClass("in");
  });
})

