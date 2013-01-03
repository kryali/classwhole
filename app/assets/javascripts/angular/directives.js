angular.module('directives', [])
.directive('autocomplete', function() {
  return domReady(function($scope, iElement, iAttrs) {
    var autocomplete = new Autocomplete();
    autocomplete.input_suggestion = ".autocomplete-suggestion";
    autocomplete.input = "#autocomplete-list";
    autocomplete.ajax_search_url = "../courses/search/auto/subject/";
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
.directive("mousehover", function($parse) {
  return {
    link: function($scope, element, attrs) {
      var fn = $parse(attrs.mousehover);
      var timeout;
      element.bind("mouseenter", function(event) {
        timeout = setTimeout(function() {
          fn($scope);
        }, 70); // threshold for mouse hover
      });
      element.bind("mouseleave", function(event) {
        clearTimeout(timeout);
      });
    }
  }
})
.directive("truncate", function() {
  return domReady(function($scope, iElement, attrs) {
    Utils.truncate(iElement, parseInt(attrs.truncate));
  });
})
.directive("fillHeight", function() {
  return domReady(function() {
    Utils.fillHeight(iElement);
  });
})
.directive("fillWidth", function() {
  return domReady(function() {
    Utils.fillWidth(iElement);
  });
})
.directive("section", function() {
  return domReady(function($scope, iElement, iAttrs) {
    Schedule.layoutSection($(iElement), $scope.section, $scope.hourRange[0]); 
  });
})
.directive("reverseText", function() {
  return {
    link: function($scope, iElement, iAttrs) {
      var text = $(iElement).text().split("").reverse().join("");
      var a = $("<a/>").attr("href", "mailto:" + text )
                       .text( text );
      $(iElement).empty().append(a);
    }
  }
});

function domReady(callback) {
  return {
    link: function($scope, iElement, iAttrs) {
      $(function() {
        // Sometimes Angular calls us before the page is completely laid out
        // Saving it for the next tick somehow fixes this. #witchcraft #fuckingwebdev
        setTimeout(function() {
          callback($scope, iElement, iAttrs);
        }, 0);
      });
    }
  }
}
