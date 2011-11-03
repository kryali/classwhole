/*
   This class sets up the jQuery autocomplete plugin and
   modifies it for us to use course search

    Example usage: (All fields required)

      autocomplete = new Autocomplete();
      autocomplete.input_suggestion = ".autocomplete-suggestion";
      autocomplete.input = "#autocomplete-list";
      autocomplete.ajax_search_url = "courses/search/auto/subject/";
      autocomplete.course_select = add_course_to_list;
      autocomplete.init();
 */

/* HACK HACK HACK (for the events */
menu = {};

function Autocomplete() { }

Autocomplete.prototype.init = function() {
    this.input_suggestion = $(this.input_suggestion);
    this.input = $(this.input);
    this.state = "closed";
    this.mode = "subject";

    extend_autocomplete_plugin();

    this.override_keyboard_for_input();

    this.input.autocomplete({ 
        source: this.ajax_search_url,
        minLength: 1,
        delay: 0,
        autoFocus: true,
        //focus: input_focus,
        select: this.subject_select,
        close: this.list_closed,
        open: this.list_opened,
    });

    menu = this;
}

/* 
    Extend the autocomplete prototype to return class titles as well as codes 
    
    We do this so we can Override the display 
    form for the autocomplete
*/ 
function extend_autocomplete_plugin() {
    var proto = $.ui.autocomplete.prototype, initSource = proto._initSource;
    $.extend( proto, { 
        _renderItem: render_item,
        ///close: function(event) { console.log("CLOSE");}
    });
}

/* Override the display */
function render_item(ul, item) {
    //console.log(item);
    var input_text = this.element.val(); 
    var bold_text = $("<strong></strong");
    var index = item.label.indexOf(input_text.toUpperCase());
    var course_label;
    if( index >= 0 ){
        var rest_of_text = item.label.substr( index + input_text.length, item.label.length - input_text.length );
        if( input_text.length > 0 && is_lower_case(input_text[input_text.length-1]))
            rest_of_text = rest_of_text.toLowerCase();
        bold_text = bold_text.append(rest_of_text);
        course_label = $("<div class='course-label'></span>")
            .append( input_text )
            .append( bold_text );
    } 
    else {
        course_label = $("<div class='course-label'></span>").append(item.label);
    }
    var title = truncate(item.title);
    var course_title = $("<div class='course-title'></span>")["html"](title);
    return $("<li></li>")
        .data( "item.autocomplete", item )
        .append($("<a></a>").append( course_label ).append( course_title ))
        .appendTo(ul);
};


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

Autocomplete.prototype.switch_to_subject_mode = function() {
    this.input.autocomplete( "option", "select", this.subject_select ); 
    this.input.autocomplete( "option", "source",  this.ajax_search_url ); 
    this.input.autocomplete( "search" );
    this.mode = "subject";
}

Autocomplete.prototype.switch_to_course_mode = function (subject_id) {
    this.input.autocomplete( "option", "select", this.course_select ); 
    this.input.autocomplete( "option", "source",  this.ajax_search_url + subject_id.toUpperCase()); 
    this.input.autocomplete( "search" );
    this.mode = "course";
}

Autocomplete.prototype.subject_select = function(event, ui) {
    //console.log("Subject Select");
    //console.log(ui.item);
    /* Prevent input box being filled */ 
    event.preventDefault();
    if ( ui.item ) {
        subject_id = ui.item.value;
        menu.input.val(subject_id);

        /* Make autocomplete query for classes now */
        menu.switch_to_course_mode(subject_id);
        /* Trigger the autocomplete */
        menu.input.autocomplete("search");
    }
};

/* ========= Helper Functions ========= */

max_string_length = undefined;
function truncate( str ){
    if( !max_string_length ){
        max_string_length = $(".user-course-list-wrapper").width();
        max_string_length = max_string_length/12;
    }
    if( str.length > max_string_length )
        return str.substring( 0, max_string_length) + "...";
    return str;
}

Autocomplete.prototype.list_closed = function() {
    menu.input_suggestion.text("");
    menu.state = "closed";
};

Autocomplete.prototype.list_opened = function() {
    menu.state = "open";
    menu.form_suggestion();
};

function is_lower_case(c) {
    if( c >= 'a' && c <= 'z' )
        return true;
    else
        return false;
}

Autocomplete.prototype.form_has_characters = function() {
    var form_value = this.input.val();
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

Autocomplete.prototype.watch_for_empty_form = function() {
    if(!this.form_has_characters()) this.switch_to_subject_mode();
};

Autocomplete.prototype.form_suggestion = function() {
    /* Get the first result from the list and set it to the background of the input form */
    var best_result = $(".ui-autocomplete .ui-menu-item .course-label").first().text();
    var list = $(".ui-autocomplete").children();
    var suggested_text = "";
    var append_string = "";

    if( this.state == "open" && list.length != 0 ) {
        current = this.input.val();
        append_string = best_result.substring(current.length);
        if( is_lower_case(current[current.length-1]))
            append_string = append_string.toLowerCase();
        suggested_text = current + append_string;
        this.input_suggestion.text(suggested_text);
    }
}

Autocomplete.prototype.watch_for_single_subject = function() {
    var results_array = $(".ui-autocomplete .ui-menu-item .course-label");
    if( results_array.length <= 0 ) return;
    var best_result = $(".ui-autocomplete .ui-menu-item .course-label").first().text();

    if( this.mode == "subject" && results_array.length == 1 ) {
        this.switch_to_course_mode(best_result);
        this.input.autocomplete("search");
    }
}


/* ========= Override Keyboard ========= */
Autocomplete.prototype.override_keyboard_for_input = function() {
    this.override_keyup();
    this.override_keydown();
}

Autocomplete.prototype.override_keyup = function() {
    this.input.keyup(function(event) {
        /* A keyup event signifies that the user has changed the input, thus do checks */
        menu.watch_for_empty_form();
        menu.watch_for_single_subject();
        menu.form_suggestion();

        var keycode = $.ui.keyCode;
        var form_value = menu.input.val();

        if(event.keyCode == keycode.SPACE) {
            /* Switch to course mode when a user types a space on a non empty form */
            menu.switch_to_course_mode(form_value.split(" ")[0]);
            /* Trigger the autocomplete */
            menu.input.autocomplete("search");
        }
        /* This means the user has used the arrows to select an item, thus clear the suggestion */
        else if (event.keyCode == keycode.DOWN || event.keyCode == keycode.UP) {
            menu.input_suggestion.text("");
        }
    });
}

Autocomplete.prototype.override_keydown = function() {
    this.input.keydown(function(event) {
        var keycode = $.ui.keyCode;
        if( event.keyCode == keycode.TAB ) {
          var best_result = $(".ui-autocomplete .ui-menu-item .course-label").first().text();
          menu.input.val(best_result);
          if( best_result != "" ) event.preventDefault();
        }
    });
}



/* ========= Unused functions ========= */
/* fix lowercase being inserted into the input form */
Autocomplete.prototype.input_focus = function (event, ui) {
    var input_text = menu.input.val(); 
    if(ui.item) {
        var replacement_string = ui.item.label; 
        if( input_text.length > 0 && is_lower_case(input_text[input_text.length-1]))
            replacement_string = replacement_string.toLowerCase();
        this.input.val(replacement_string);
        event.preventDefault();
    }
};
