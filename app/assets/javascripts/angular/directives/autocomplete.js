angular.module('directives').directive('autocomplete', ['$parse', function($parse) {
  return domReady(function($scope, iElement, attrs) {
    var autocomplete = new Autocomplete();
    var fn = $parse(attrs.aSelected);
    autocomplete.input_suggestion = ".autocomplete-suggestion";
    autocomplete.input = "#autocomplete-list";
    autocomplete.ajax_search_url = "/courses/search/auto/subject/";
    autocomplete.course_select = execute;
    autocomplete.init();

    function execute(event, ui) {
      event.preventDefault();
      if ( ui.item ) {
        autocomplete.clear();
        $scope.$apply(function($scope) {
          fn($scope, {courseId: ui.item.id});
        });
      }
    }
  });
}]);
