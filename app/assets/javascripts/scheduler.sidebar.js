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

  for( i in section.meetings ) {
    var meeting = section.meetings[i].table;
    row.append( $("<span/>")
                .addClass("hidden id")
                .text( section.id ) ); 
    row.append( $("<span/>")
                .addClass("section-type label")
                .text( section.short_type ) ); 

    var instructor_name;
    if (meeting.instructors.length >= 1)  {
      instructor_name = meeting.instructors[0];
    } else {
      instructor_name = "TBD";
    }

    row.append( $("<span/>")
                .addClass("instructor")
                .text( instructor_name ) ); 
    row.append( $("<span/>")
                .addClass("code")
                .text( section.code ) ); 
    row.append( $("<span/>")
                .addClass("enrollment status-" + section.enrollment_status) );
    row.append( $("<span/>")
                .addClass("time")
                .text(print_time(meeting.start_time) + "-" + print_time(meeting.end_time))); 
  }
  return row;
}
