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

  this.override_keyboard_for_input();

  var that = this;
  $.ajax({
    type: 'GET',
    url: 'json/subject/all',
    success: function( data, textStatus, xhQR ) {
      that.start(data);
    }
  });
  extend_autocomplete_plugin(this);
  override_search();
  this.cache = {};
  menu.fetching = false;
  menu = this;
}

Autocomplete.prototype.start = function(data) {
  this.subject_data_source = data;
  this.input.autocomplete({ 
    source: this.subject_data_source,
    minLength: 1,
    delay: 0,
    autoFocus: true,
    select: this.subject_select,
    close: this.list_closed,
    open: this.list_opened,
  });
  this.input.autocomplete( "search" );
}

/* 
   Extend the autocomplete prototype to return class titles as well as codes 

   We do this so we can Override the display 
   form for the autocomplete
   */ 
function extend_autocomplete_plugin(that) {
  var proto = $.ui.autocomplete.prototype;
  $.extend( proto, { 
    _renderItem: render_item,
  });
}

function override_search() {
  var proto = $.ui.autocomplete.prototype;
  $.extend(proto, { 
    _search: function(value) {
      if ( typeof this.options.source == "string" ) {
        var url = this.options.source;
        var that = this;
        if (menu.fetching) return;
        menu.fetching = true;
        $.getJSON(url, function(data) {
          menu.fetching = false;
          if (data.success == false) return;
          var key = menu.subject_code;
          menu.cache[key] = data;
          menu.input.autocomplete("option", "source", data);
          that.response(search(value, data));
        });
      } else {
        this.response(search(value, this.options.source));
      }
    },
  });
}

function search(term, data) {
  var found = [];
  if (!term || term.length <= 0) return found;
  for (var i = 0; i < data.length; i++) {
    if (match(term, data[i])) {
      found.push(data[i]);
    }
  }
  return found;
}

function match(term, data) {
  var termStr = term.toUpperCase();
  var dataStr = data.label.toUpperCase();
  for (var i = 0; i < termStr.length; i++) {
    if (termStr[i] != dataStr[i]) {
      return false;
    }
  }
  return true;
}

/* Override the display */
function render_item(ul, item) {
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
  if (this.mode == "subject") return; // No need to switch.
  menu.subject_code = undefined;
  this.input.autocomplete( "option", "select", this.subject_select ); 
  this.input.autocomplete( "option", "source",  this.subject_data_source ); 
  this.input.autocomplete( "search" );
  this.mode = "subject";
}

Autocomplete.prototype.switch_to_course_mode = function (subject_id) {
  if (this.mode == "course") return; // No need to switch.
  menu.subject_code = subject_id.toUpperCase();
  var data_source;
  if (typeof menu.cache[menu.subject_code] == "undefined") {
    data_source = 'json/subject/' + menu.subject_code + '/courses';
  } else {
    data_source = menu.cache[menu.subject_code];
  }
  this.input.autocomplete( "option", "select", this.course_select ); 
  this.input.autocomplete("option", "source", data_source);
  this.input.autocomplete("search");
  this.mode = "course";
}

Autocomplete.prototype.subject_select = function(event, ui) {
  /* Prevent input box being filled */ 
  event.preventDefault();
  if ( ui.item ) {
    subject_id = ui.item.value;
    menu.input.val(subject_id + " ");

    /* Make autocomplete query for classes now */
    menu.switch_to_course_mode(subject_id);
    /* Trigger the autocomplete */
    menu.input.autocomplete("search");
  }
};

Autocomplete.prototype.clear = function() {
  menu.input.val("");
}

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

function form_has_characters(form) {
  var form_value = form.val();
  for(var i = 0; i < form_value.length; i++){

    /* If character is a letter or a number */
    if(   (form_value[i] >= "A" && form_value[i] <= "Z")
        || (form_value[i] >= "0" && form_value[i] <= "9")
        || (form_value[i] >= "a" && form_value[i] <= "z")) {
      return true;
    }
  }
  /* No letters or numbers found */
  return false;
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

function is_single_subject() {
  if (this.mode != "subject") return false;
  var results_array = $(".ui-autocomplete .ui-menu-item .course-label");
  if( results_array.length <= 0 ) return;
  var best_result = $(".ui-autocomplete .ui-menu-item .course-label").first().text();

  if(results_array.length == 1) {
    return best_result;
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

    var single_subject = is_single_subject();
    if (single_subject) {
      menu.switch_to_course_mode(single_subject);
      return;
    }

    if (menu.mode == "course" && menu.input.val().indexOf(" ") == -1) {
      menu.switch_to_subject_mode();
      return;
    }

    menu.form_suggestion();
    /* A keyup event signifies that the user has changed the input, thus do checks */

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
