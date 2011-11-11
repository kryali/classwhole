$(document).ready(function(){
  
  var class_list = new ClassList();
  var autocomplete = new Autocomplete();
  autocomplete.input_suggestion = ".autocomplete-suggestion";
  autocomplete.input = "#autocomplete-list";
  autocomplete.ajax_search_url = "../courses/search/auto/subject/";
  autocomplete.course_select = class_list.add_class_callback;
  autocomplete.init();
  class_list.init();

  $(".schedule").click( function(event) {
    if(!class_list.has_classes()) {
      pop_alert("error", "No classes selected.");
      event.preventDefault();
      return true;
    }
  });

});
