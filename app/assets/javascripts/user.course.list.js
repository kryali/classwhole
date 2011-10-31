class_counter = 0;
has_classes = false;
selected_classes = {};

function ClassList(){ }

ClassList.prototype.init = function() {
    $(".user-course-list ul li ").each( function(index) { 
        has_classes = true;
        var class_id = $(this).find(".code").text(); 
        selected_classes[class_id] = $(this);
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
        show_button();
        var class_id = ui.item.value;
        if( class_id in selected_classes ){
            /* return if the user as already selected the class*/
            pop_alert("error", class_id, " is already selected");
            selected_classes[class_id].animate({
                backgroundColor: '#F08080',
            }, 100, function() {
                $(this).animate({backgroundColor: 'white'}, 500, undefined);
            });

            test = selected_classes[class_id];
            //test.css("background", "red");
            return;
        } 

        /* Append the course to the currently populated list */
        var remove_course = $("<a/>").text("X").attr("href", "#").addClass("remove-link");
        var course_li = $("<li/>")
                            .append(remove_course)
                            .append($("<span/>")
                                .text(ui.item.label)
                                .addClass("code"))
                            .append($("<span/>")
                                .text(ui.item.title)
                                .addClass("title"))
                            .css("display", "none");
        course_li.appendTo(".user-course-list ul");
        course_li.slideDown();

        remove_course.click( function() {
            var removed = 0;
            // Search through the hidden form and remove this element
            $(".hidden-course-form").children().each( function(i) {
                if($(this).val() == class_id){
                    $(this).remove();
                    removed++;
                } else if ($(this).attr("name") == "size"){
                    var current_size = $(this).val();
                    $(this).val(current_size - removed );
                };
            });
            course_li.slideUp();
            $(this).remove();
            delete selected_classes[class_id];
        });

        selected_classes[class_id] = course_li;

        /* Add the course id to our hidden form */
        add_course_id_to_hidden_form(class_id);
        class_counter++;
			
					/* Call add courses */
			var string_class_id = class_id.toString();		    
			$.ajax({
		      type: 'POST',
		      data: { size: "1", 0:string_class_id},
		      url:  '/user/courses/new',
		      success: function(data, textStatus, jqXHR) {
		        update_schedule(data, textStatus, jqXHR, undefined);
		      }
		    });
				

        /* use a form to keep track of count */
        $("<input>").val(class_counter)
            .attr("type", "hidden")
            .attr("name", "size")
            .appendTo(".hidden-course-form");
    }

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
    var header = $("<h1/>").text("Spring 2011").addClass("hidden");
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
