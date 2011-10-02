$(document).ready(function(){
  
  /* Keep track of the number of classes the user is inputting */
  var class_counter = 0;
  var selected_classes = {};
  var autocomplete_div = "#autocomplete-course-list";

  var ajax_search_url = "courses/search/auto/subject/";

  /* So there are two main modes for the autocomplete form, subject and course mode
   * 
   *  1. Subject Mode (default): - form searches subjects rather than classes
   *                             - autocomplete select doesn't inject into the list
   *                             - switches to course mode on selection
   *
   *      Triggers:   input field is empty 
   *                  no spaces exist in input
   *
   *  2. Course Mode:  form searches for classes after a subject has been found
   *                   autocomplete select does inject into the list
   *
   *      Triggers:   subject is selected
   *                  a space exists in the input
   *
   *
   *  Approach: 
   */

  function switch_to_subject_mode() {
    $(autocomplete_div).autocomplete( "option", "select", subject_select ); 
    $(autocomplete_div).autocomplete( "option", "source",  ajax_search_url ); 
  }

  function switch_to_course_mode(subject_id) {
    $(autocomplete_div).autocomplete( "option", "select", add_course_to_list ); 
    $(autocomplete_div).autocomplete( "option", "source",  ajax_search_url + subject_id); 
  }

  /* In order to send a list of class ids to rails, we need to silently 
     keep track of the class ids in a hidden form as well as send the size of the list */
  var add_course_id_to_form = function( course_id ) { 

    $("<input>").val(course_id)
                .attr("type", "hidden")
                .attr("name", class_counter)
                .appendTo("#hidden-course-form");

  };

  var add_course_to_list = function( event, ui ) {

    /* Prevent input box being filled */ 
    event.preventDefault();
    $(autocomplete_div).val(""); 

    if ( ui.item ) {
      var class_id = ui.item.value;
      if( class_id in selected_classes ){
        /* return if the user as already selected the class*/
        pop_alert("error","class is already selected"); // REMOVE THIS LATER
        return;
      } else {
        selected_classes[class_id] = class_counter;
      }

      /* Append the course to the currently populated list */
      $("<li/>").text(ui.item.label).appendTo("#user-course-list ul");

      /* Add the course id to our hidden form */
      add_course_id_to_form(class_id);
      class_counter++;

      /* use a form to keep track of count */
      $("<input>").val(class_counter)
                  .attr("type", "hidden")
                  .attr("name", "size")
                  .appendTo("#hidden-course-form");
    }

    switch_to_subject_mode();
  };

  var subject_id = undefined;
  function subject_select(event, ui) {
    /* Prevent input box being filled */ 
    event.preventDefault();
    if ( ui.item ) {
      console.log("Switching to class search");
      subject_id = ui.item.value;
      console.log(subject_id);
      /* Make autocomplete query for classes now */

      /* insert a space into the input */
      $("#autocomplete-course-list").val($("#autocomplete-course-list").val() + " ");
      switch_to_course_mode(subject_id);
      /* Trigger the autocomplete */
      $(autocomplete_div).autocomplete("search");
    }
  };

  function form_has_characters() {
    var form_value = $(autocomplete_div).val();
    for(var i = 0; i < form_value.length; i++){

      /* If character is a letter or a number */
      if(   (form_value[i] >= "A" && form_value[i] <= "Z")
         || (form_value[i] >= "0" && form_value[i] <= "9")) {
         return true;
      }
    }
    /* No letters or numbers found */
    return false;
  };

  /* Switch to course mode when a user types a space on a non empty form */
  $(autocomplete_div).keyup(function(event) {
    var form_value = $(autocomplete_div).val();
    if(event.keyCode == "32" && form_has_characters()) {
      switch_to_course_mode(form_value.split(" ")[0]);
      /* Trigger the autocomplete */
      $(autocomplete_div).autocomplete("search");
    }
  });

  /* Set up autocomplete, use a rails catalog helper function to populate data */
  $(autocomplete_div).autocomplete({ 
    source: ajax_search_url,
    minLength: 1,
    delay: 0,
    autoFocus: true,
    select: subject_select,
  });

  var watch_for_empty_form = function() {
    if(!form_has_characters()){
      switch_to_subject_mode();
    };
  };

  self.setInterval(function(){
    watch_for_empty_form();
  }, 300);

});
