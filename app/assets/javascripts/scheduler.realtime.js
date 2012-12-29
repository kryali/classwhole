$(document).ready(function() {
  init();
  var autocomplete = initialize_autocomplete();

  selected_classes = {};
  init_sidebar();

  function add_course_callback(event, ui) {

    event.preventDefault();
    if ( ui.item ) {
        var class_id = ui.item.id;
        if( class_id in selected_classes ){
            /* return if the user as already selected the class*/
            pop_alert("error", ui.item.value, " is already selected");
            selected_classes[class_id].animate({
                backgroundColor: '#F08080',
            }, 100, function() {
                $(this).animate({backgroundColor: 'white'}, 500, undefined);
            });
            return;
        }

        console.log( class_id );
        autocomplete.clear();
        pop_alert("info", "scheduling..");
        $.ajax({
            type: 'POST',
            data: { id: class_id },
            dataType: 'json',
            url:  '/scheduler/courses/new',
            success: function( data, textStatus, xh ) {
              console.log( data );
              if( data.status == "success" ) {
                fetch_schedule(data, textStatus);
                var row = $(data.sidebar_row);
                $("ul.courses").append( row );
                init_sidebar();
              } else {
                pop_alert( data.status, data.message );
              }
            }
          });

        //mpq.track("Class added");
        /* Append the course to the currently populated list */
        //var remove_course = $("<a/>").text("X").addClass("remove-link");
        //max_hours += parseInt(ui.item.max_hours);
        //min_hours += parseInt(ui.item.min_hours);
        //update_hours();
        //num_classes++;

        /*
        remove_course.click( function() {
          $.ajax({
            type: 'GET',
            url:  '/user/courses/destroy/'+ui.item.id,
          });
          course_li.slideUp();
          $(this).remove();
          num_classes--;
          max_hours -= parseInt( ui.item.max_hours );
          min_hours -= parseInt( ui.item.min_hours );
          update_hours();
          delete selected_classes[class_id];
        });

        selected_classes[class_id] = course_li;
        */
    }
  }

  function init_sidebar() {
    $(".remove-course-link").click( function() {
      var course = $(this).closest("ul");
      var course_id = parseInt(course.attr("data-course-id"));
      course.slideUp( 500, function() {
        $(this).remove();
      });
      $.ajax({
        type: 'GET',
        url:  '/scheduler/courses/destroy/'+course_id,
        success: function( data, textStatus ) {
          if( data.status == "success" ) {
            fetch_schedule(data, textStatus);
          } else {
            pop_alert( data.status, data.message );
          }
        }
      });
    });
  }

  function initialize_autocomplete(){
    var autocomplete = new Autocomplete();
    autocomplete.input_suggestion = ".autocomplete-suggestion";
    autocomplete.input = "#autocomplete-list";
    autocomplete.ajax_search_url = "../courses/search/auto/subject/";
    autocomplete.course_select = add_course_callback;
    autocomplete.init();
    return autocomplete;
    //class_list.init();
  }

});
