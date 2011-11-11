/*
  Scheduler takes in a json array of section objects and renders a
  html presentable layout
 */

var days = ['M', 'T', 'W', 'R', 'F'];
var block_height = 48;
var header_height = 34;

function Schedule( sections, start_hour, end_hour  ) { 
  this.init( sections, start_hour, end_hour  );
}

Schedule.prototype.init = function( sections, start_hour, end_hour ) {
  this.sections = sections;
  this.wrapper = $("<div/>").addClass("schedule-wrapper");
  this.pick_colors();
  this.render_day_grid();
  this.render_time_labels( start_hour - 1 , end_hour + 2 );
  this.render_sections( this.sections );
};

Schedule.prototype.render = function() {
  return this.wrapper;
}

Schedule.prototype.add_hints = function( section_hints ) {
  for( i in section_hints ) {
    var section = section_hints[i];
    this.render_section( section, true );
  }
}

Schedule.prototype.render_sections = function( sections ) {
  for( i in sections ) {
    var section = sections[i];
    this.render_section( section );
  }
}

Schedule.prototype.render_section = function( section, is_hint ) {
  var section_block = $("<div/>")
                      .addClass("schedule-block")
                      .attr("days", section.days);
  var start_time = new Date(section.start_time);
  var end_time = new Date(section.end_time);

  // Find duration and offset
  var duration_scale = duration( start_time, end_time );
  var height = block_height * duration_scale;

  var offset = ( (start_time.getUTCHours() - this.day_start_time) + ( start_time.getUTCMinutes()/60 )) * block_height;

  fill_section_info( section, section_block );
  
  section_block.height( height );
  section_block.css("top", Math.abs(offset) + header_height + "px");
  section_block.addClass( this.colors[ section.course_id ] );

  // If it's a hint, wrap the section block in a droppable div
  if( is_hint ) {
    section_block = $("<div/>").addClass("droppable").append( section_block );
  }

  // Add the section block to all the days
  var section_days = section.days.split("");
  for( j in section_days ) {
    this.days[ section_days[j] ].append( section_block.clone() );
  }
}

function fill_section_info( section, section_block ) {
  section_block.append( $("<span/>")
                        .addClass("hidden id")
                        .text(section.id) );
  section_block.append( $("<span/>")
                        .addClass("hidden crn")
                        .text(section.reference_number) );
  section_block.append( $("<span/>")
                        .addClass("section-code")
                        .text(section.code) );
  section_block.append( $("<span/>")
                        .addClass("course-name")
                        .text( section.course_subject_code + " " + section.course_number) );
  section_block.append( $("<span/>")
                        .addClass("course-title")
                        .text( section.course_title ) );
  section_block.append( $("<span/>")
                        .addClass("section-type label")
                        .text( section.section_type ) );
  section_block.append( $("<span/>")
                        .addClass("duration")
                        .text( print_time( section.start_time) + "-" + print_time( section.end_time) ) );
}

Schedule.prototype.pick_colors = function() {
  this.colors = {};
  var colors_current = 0;
  //sections.sort!
  for( i in this.sections) {
    var section = this.sections[i];
    if( ! this.colors[ section.course_id ] ) {
      this.colors[ section.course_id ] = "color-" + colors_current;
      colors_current++;
    }
  }
}


function hr_to_s( hour ) {
  return hour;
}

function day_header( day ) {
  switch( day ) {
    case "M":
      return "Monday";
    case "T":
      return "Tuesday";
    case "W":
      return "Wednesday";
    case "R":
      return "Thursday";
    case "F":
      return "Friday";
    default:
      return "lulzwut?";
  }
}
Schedule.prototype.render_day_grid = function() {
  this.days = {};
  for( var i = 0; i < days.length; i++) {
    var schedule_day = $("<ul/>")
                        .addClass("schedule-day " + days[i])
                        .attr("day", days[i]);
    schedule_day.prepend( $("<li/>")
                         .append(day_header( days[i] ))
                         .addClass("header"));
    this.days[ days[i] ] = schedule_day;
    this.wrapper.append( this.days[ days[i] ] );
  }
}

Schedule.prototype.render_time_labels = function( start_time , end_time ) {
  this.day_start_time = start_time;
  this.day_end_time = end_time;

  // Generate time list
  var time_list = $("<ul/>").addClass("time-label");

  for( var current_time = start_time; current_time < end_time; current_time++ ) {
    var time_block = $("<li/>").text( print_hour(current_time) );
    time_list.append( time_block );
    for( i in days ) {
      this.days[ days[i] ].append( $("<li/>") );
    }
  }

  this.wrapper.prepend( time_list );
}

function print_time(time) {
  time = new Date(time);
  var hour = time.getUTCHours();
  var am_pm = "";
  if( hour >= 12 ) 
    am_pm = "pm";
  else
    am_pm = "am";

  hour = hour % 12;
  if(hour == 0) {
    hour = 12;
  }

  return hour + ":" + ("0" + time.getUTCMinutes()).slice(-2) + am_pm;
}

function print_hour(hour) {
  if( hour > 12 && hour < 24)
    return (hour-12) + " pm"
  else if ( hour < 12 && hour != 0)
    return hour + " am"
  else if ( hour == 24 )
    return (hour-12) + " am"
  else if ( hour == 12 )
    return hour + " pm"
  else
    return "nil"
}

function duration( start_time, end_time ) {
  var hours = end_time.getUTCHours() - start_time.getUTCHours();
  var minutes = end_time.getUTCMinutes() - start_time.getUTCMinutes();
  return (hours + minutes/60);
}
