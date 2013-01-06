angular.module('directives').directive("reverseText", function() {
  return {
    link: function($scope, iElement, iAttrs) {
      var text = $(iElement).text().split("").reverse().join("");
      var a = $("<a/>").attr("href", "mailto:" + text )
                       .text( text );
      $(iElement).empty().append(a);
    }
  }
});
