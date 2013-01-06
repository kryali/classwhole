angular.module('directives').directive("section", function() {
  return domReady(function($scope, element, attrs) {
    function startDrag() {
      $scope.$emit('startDrag');
    }

    function endDrag() {
      $scope.$emit('endDrag');
    }

    var options = {
      draggable: {
        //snap:        '.ui-droppable',
        //snapMode:    'inner',
        //snapTolerance: 20,
        start:       startDrag,
        stop:        endDrag,
        revert:      true,
        //revertDuration: 200,
        //scope:        'section_hint',
        //refreshPositions: true,
        zIndex:       10,
      },
      droppable: {
        accept:      '.ui-draggable',
        hoverClass:  'hover',
        //drop:        handle_drop,
        scope:        'section_hint',
      }
    };
    var sectionElement = $(element);
    Schedule.layoutSection(sectionElement, $scope.section, $scope.hourRange[0]); 
    if (attrs.hint) {
      sectionElement.draggable(options.draggable);
    } else {
      sectionElement.droppable(options.droppable);
    }
  });
})

