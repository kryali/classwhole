var class_counter = 0;
var has_classes = false;
var selected_classes = {};
var course_destroy_url  = '/user/courses/destroy/';

function ClassList(){ }

ClassList.prototype.init = function() {
    $(".user-course-list ul li ").each( function() { 
        has_classes = true;
        var class_id = $(this).find(".id").text(); 
        selected_classes[class_id] = $(this);

        var class_li = $(this);
        $(this).find(".remove-link").click( function() {
          mpq.track("Class removed");
					$.ajax({
								type: 'GET',
                url: course_destroy_url + class_id,
                success: function() {
                  delete selected_classes[ class_id ];
                  class_li.slideUp(function(){ $(this).remove() });
                }
					});
        });
    });
}

ClassList.prototype.add_class_callback = function(event, ui) {
    var keycode = $.ui.keyCode;
    if( event.keyCode == keycode.TAB ) {
        /* If the user hit a tab, we don't want to add it just yet */
        return;
    }
    /* Prevent input box being filled */ 
    event.preventDefault();
    this.value = ""; 

    if ( ui.item ) {
        mpq.track("Class added");
        show_button();
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

        /* Append the course to the currently populated list */
        var remove_course = $("<a/>").text("X").addClass("remove-link");
        var course_li = $("<li/>")
                            .append(remove_course)
                            .append($("<span/>")
                                .text(ui.item.label)
                                .addClass("code"))
                            .append($("<span/>")
                                .text(ui.item.title)
                                .addClass("title"))
                            .append($("<span/>")
                                .text(ui.item.title)
                                .addClass("hidden id"))
                            .css("display", "none");
        course_li.appendTo(".user-course-list ul");
        course_li.slideDown();

        remove_course.click( function() {
            mpq.track("Class removed");
            var removed = 0;
            $.ajax({
								type: 'GET',
								url:  '/user/courses/destroy/'+ui.item.id,
							});
            course_li.slideUp();
            $(this).remove();
            delete selected_classes[class_id];
        });

        selected_classes[class_id] = course_li;

					/* Call add courses */
			var string_class_id = class_id.toString();		    
			$.ajax({
		      type: 'POST',
		      data: { id: class_id },
		      url:  '/user/courses/new',
		    });
				
    }

}

ClassList.prototype.has_classes = function() {
  return has_classes;
}

function show_button() {
    if( has_classes ) return;
    /*
    $(".hidden-course-form .btn.primary.hidden")
        .animate({
            display: 'inline',
          }, 200, undefined)
        .removeClass("hidden");
    */

    $(".user-course-list span.hint")
        .animate({
            opacity: 0,
            display: 'none',
          }, 200, function() {
            $(this).slideUp();
          });


    var course_list = $(".user-course-list");
    var header = $("<h1/>").text("Spring 2012").addClass("hidden");
    course_list.prepend(header);
    header.slideDown();

    has_classes = true;
};

/* In order to send a list of class ids to rails, we need to silently 
   keep track of the class ids in a hidden form as well as send the size of the list */
var add_course_id_to_hidden_form = function( course_id ) { 
    $("<input>").val(course_id)
        .attr("type", "hidden")
        .attr("name", class_counter)
        .appendTo(".hidden-course-form");
};
