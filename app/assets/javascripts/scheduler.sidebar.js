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

  var time_s = hour + ":" + ("0" + time.getUTCMinutes()).slice(-2) + am_pm;
  time_s = time_s.replace(/:00/, "");
  return time_s;
}

function Sidebar( sections  ) { 
  this.sections = sections;
}

function show_prof_path( name ) {
  var slug = name.replace(", ", "-");
  return "http://classwhole.com/profs/" + slug
}

function print_type( type ) {
  if( type == "online" ) return "ONLINE/iARR";
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
    var instructor;
    if (meeting.instructors.length >= 1)  {
      instructor_name = meeting.instructors[0];
      instructor =  $("<a/>")
                    .attr("href", show_prof_path(instructor_name ))
                    .attr("target", "_BLANK")
                    .text( instructor_name );
    } else {
      instructor_name = "TBD";
      instructor = instructor_name;
    }

    row.append( $("<span/>")
                .addClass("instructor")
                .append( instructor ));
    row.append( $("<span/>")
                .addClass("code")
                .text( section.code ) ); 
    row.append( $("<span/>")
                .addClass("enrollment status-" + section.enrollment_status)
                .attr("title", section.reason) );
    if( meeting.start_time && meeting.end_time ) {
      row.append( $("<span/>")
                  .addClass("time")
                  .text(print_time(meeting.start_time) + "-" + print_time(meeting.end_time))); 
    } else {
      console.log( meeting );
      row.append( $("<span/>")
                  .addClass("time")
                  .text( print_type(meeting.class_type) )); 
    }
  }
  return row;
}
