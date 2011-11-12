$(document).ready(function(){

  // Let class_list be available to all functions by declaring it out of function scope
  var class_list = new ClassList();

  initialize_autocomplete();
  $(".schedule").click( function(event) {
    if(!class_list.has_classes()) {
      pop_alert("error", "No classes selected.");
      event.preventDefault();
      return true;
    }
    mpq.track("Schedule created");
  });

  /* This refreshes the course list once a user has logged into facebook */
  $(document).bind('logged-in', function(){
    $(document).unbind('logged-in');
      $.ajax({
        type: 'POST',
        url:  '/user/refresh',					
        success: function( data, textStatus, xqHR){    	
          $("div.user-course-list").empty();
          $("div.user-course-list").append( $(data) );
          initialize_autocomplete();
        }
      });
  });

  function initialize_autocomplete(){
    var autocomplete = new Autocomplete();
    autocomplete.input_suggestion = ".autocomplete-suggestion";
    autocomplete.input = "#autocomplete-list";
    autocomplete.ajax_search_url = "../courses/search/auto/subject/";
    autocomplete.course_select = class_list.add_class_callback;
    autocomplete.init();
    class_list.init();
  }

});
