angular.module('directives').directive('autocomplete', function() {
  return domReady(function($scope, iElement, iAttrs) {
    var autocomplete = new Autocomplete();
    autocomplete.input_suggestion = ".autocomplete-suggestion";
    autocomplete.input = "#autocomplete-list";
    autocomplete.ajax_search_url = "/courses/search/auto/subject/";
    autocomplete.course_select = add_course_callback;
    autocomplete.init();

    function add_course_callback(event, ui) {
      event.preventDefault();
      if ( ui.item ) {
        autocomplete.clear();
        $scope.$apply(function($scope) {
          $scope.addCourse(ui.item.id);
        });
      }
    }
  });
})
