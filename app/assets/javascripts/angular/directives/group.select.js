angular.module('directives').directive('newSelect', ['$parse', function($parse) {
  return domReady(function($scope, iElement, attrs) {
    var groups = JSON.parse(attrs.newSelect);
    attrs.$set('newSelect', '');
    var fn = $parse(attrs.onSelect);
    var selectedGroup = attrs.selectedGroup;
    var select = $(iElement);
    if (groups.length <= 1) {
      select.hide();
      return;
    }
    for(var i = 0; i < groups.length; i++) {
      var value = groups[i].course_id + "," + groups[i].key;
      var option = $("<option/>").val(value).text(groups[i].key);
      select.val(groups[i].course_id + "," + selectedGroup);
      select.append(option);
    }
    select.change(function() {
      var data = select.val().split(",");
      var courseId = data[0];
      var key = data[1];
      $scope.$apply(function($scope) {
        fn($scope, {courseId: courseId, groupKey: key});
      });
    });
  });
}]);
