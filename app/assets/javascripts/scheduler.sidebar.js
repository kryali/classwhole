/*
 * HTML representation of the sidebar
 */

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

function Sidebar( sections  ) { 
  this.sections = sections;
}

Sidebar.prototype.render_section_row = function( section ) {
  var row = $("<div/>");
  row.append( $("<span/>")
              .addClass("hidden id")
              .text( section.id ) ); 
  row.append( $("<span/>")
              .addClass("section-type label")
              .text( section.section_type ) ); 
  row.append( $("<span/>")
              .addClass("instructor")
              .text( section.instructor ) ); 
  row.append( $("<span/>")
              .addClass("code")
              .text( section.code ) ); 
  row.append( $("<span/>")
              .addClass("time")
              .text(print_time(section.start_time) + "-" + print_time(section.end_time))); 
  return row;
}
