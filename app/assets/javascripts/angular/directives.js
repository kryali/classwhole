angular.module('directives', [])
  .directive('autocomplete', function() {
    return {
      link: function (scope, iElement, iAttrs) {
              $(function() {
                var autocomplete = new Autocomplete();
                autocomplete.input_suggestion = ".autocomplete-suggestion";
                autocomplete.input = "#autocomplete-list";
                autocomplete.ajax_search_url = "../courses/search/auto/subject/";
                autocomplete.course_select = add_course_callback;
                autocomplete.init();

                function add_course_callback(event, ui) {
                  event.preventDefault();
                  if ( ui.item ) {
                    var class_id = ui.item.id;
                    console.log(class_id);
                    autocomplete.clear();
                    scope.$apply(function($scope) {
                      console.log("Callback scope: " + $scope.$id);
                      console.log($scope);
                      $scope.addCourse(class_id);
                    });
                  }
                }
              });
            }
    }
  });
