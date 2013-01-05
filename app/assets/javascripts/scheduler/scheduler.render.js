function Schedule() { 
}

Schedule.prototype.render_section = function( section, is_hint ) {
  section_block = $("<div/>").addClass("droppable").append( section_block );
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

Schedule.layoutSection = function(sectionElement, section, globalStartHour) {
  var section_height = $("ul.schedule-day li").height();
  var section_width = $("ul.schedule-day li").width();

  var height, start_hour, start_min, end_hour, end_min, y_offset, x_offset;
  var days = ["M", "T", "W", "R", "F"];
  var day = section.day;

  // y_offset
  start_hour = section.start_time.hour;
  start_min = section.start_time.min / 60;

  y_offset = ((start_hour - globalStartHour) * (section_height + 1)); // +1 border
  y_offset += start_min * section_height;

  // x_offset
  x_offset = $($("ul.schedule-day").get(days.indexOf(day))).position().left;

  // height 
  end_hour = section.end_time.hour;
  end_min = section.end_time.min / 60;
  height = ((end_hour - start_hour) + end_min - start_min) * section_height;

  sectionElement.css("left", x_offset);
  sectionElement.css("top", y_offset);
  sectionElement.css("width", section_width - 2); // -2 for borders
  sectionElement.css("height", height);
  sectionElement.css("display", "block");
  if (height < 63) { // Yep, this is arbitrary. Don't like it? FIX IT
    sectionElement.find(".course-title").css("display", "none");
  }
};
