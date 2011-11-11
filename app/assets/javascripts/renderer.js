$(function(){
  var render = document.getElementById('schedule-render');

  var course_colors = ["#33CCFF", "#00CC66", "#FF3333", "#FF9900", "#CC33CC", "#99FF00", "#FFFF00"];
  // blue, darker blue green, reddish pink, orange, purple, yellowish green
  var background_colors = ["#EEEEEE", "#AAAAAC", "#EEEEEE"];
  
  var left_offset = 50;
  var top_offset = 30;
  var block_width = 122
  var block_height = 75;
  var text_offset = 5;

  var start_time;
  var end_time;

  for (var i = 0; i < sections.length; i++) {
    var start = new Date(sections[i]["start_time"]);
    var end = new Date(sections[i]["end_time"]);
    if(start_time == null || start < start_time)
      start_time = start;
    if(end_time == null || end > end_time)
      end_time = end;
  }

  var start_hour = start_time.getUTCHours() - 1;
  var end_hour = end_time.getUTCHours() + 2;

  render.width = left_offset + (5 * block_width);
  render.height = top_offset + ((end_hour-start_hour) * block_height);
  var context = render.getContext('2d');

  draw_background(start_hour, end_hour);
  var uniques = []
  for (var i = 0; i < sections.length; i++) {
    var section = sections[i];
    var code = section["course_subject_code"] + section["course_number"];
    if( uniques.indexOf(code) == -1 ) {
      uniques.push(code);
    }
    draw_section(time_float(start_time) - 1, section, course_colors[uniques.indexOf(code)]);
  }

  $(".download-schedule").click( function() {
    Canvas2Image.saveAsPNG(render);
  });

  function draw_background(start_hour, end_hour) {
    var hours = end_hour - start_hour;
    context.font = "10pt Arial";
    context.fillStyle = "#000000";

    // draw days of week
    context.textBaseline = "middle";
    context.textAlign = "center";
    context.fillText("Monday", left_offset + block_width/2, top_offset/2);
    context.fillText("Tuesday", left_offset + block_width + block_width/2, top_offset/2);
    context.fillText("Wednesday", left_offset + 2*block_width + block_width/2, top_offset/2);
    context.fillText("Thursday", left_offset + 3*block_width + block_width/2, top_offset/2);
    context.fillText("Friday", left_offset + 4*block_width + block_width/2, top_offset/2);

    // draw rectangles around days of week
    for (var i = 0; i < 5; i++) {
      context.strokeRect(left_offset + i*block_width, 0, block_width, top_offset);
    }

    // draw times
    context.textAlign = "right";
    for (var j = 0; j < hours; j++) {
      var display_hour = start_hour+j;
      var suffix;
      if(display_hour > 11) {
        suffix = " PM";
      }
      else {
        suffix = " AM";
      }
      display_hour %= 12;
      if(display_hour == 0) {
        display_hour = 12;
      }      
      context.fillText(display_hour.toString() + suffix, left_offset - 5, top_offset + j*block_height, left_offset);
    }
  
    // draw background blocks
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < hours; j++) {
        var x = left_offset + i * block_width;
        var y = top_offset + j * block_height;
        context.fillStyle = background_colors[0];
        context.fillRect(x, y, block_width, block_height);
        context.fillStyle = background_colors[1];
        context.strokeRect(x, y, block_width, block_height);
      }
    }
  }

  function draw_section(start_hour, section, color) {
    var start_time = new Date(section["start_time"]);
    var end_time = new Date(section["end_time"]);
    var start_position = block_height * (time_float(start_time) - start_hour);
    var end_position = block_height * (time_float(end_time) - start_hour);
    var height = end_position - start_position;

    var days = section["days"];

    var section_name = section["course_subject_code"] + " " + section["course_number"];
    var section_type = section["section_type"];
    var section_time = time_string(start_time) + " - " + time_string(end_time);
    var section_room = section["room"] + " " + section["building"];

    for(var i = 0; i < days.length; i++) {
      var index = day_index(days.charAt(i));
      if(index == -1) { 
        continue; 
      }
      var x = left_offset + index * block_width;
      var y = top_offset + start_position;
      // block
      context.fillStyle = color;
      context.fillRect(x, y, block_width, height);
      context.fillStyle = "black";
      context.strokeRect(x, y, block_width, height);
      // text
      context.textBaseline = "top";
      context.textAlign = "left";
      context.fillText(section_name, x + text_offset, y + text_offset);
      context.textAlign = "right";
      context.fillText(section_type, x + block_width - text_offset, y + text_offset);
      context.fillText(section_room, x + block_width - text_offset, y + text_offset + 20);
      context.textBaseline = "bottom";
      context.fillText(section_time, x + block_width - text_offset, top_offset + end_position - text_offset);
    }
  }
  
  function time_string(time) {
    var hour = time.getUTCHours() % 12;
    if(hour == 0) hour = 12;
    return hour + ":" + ("0" + time.getUTCMinutes()).slice(-2);
  }

  function time_float(time) {
    return time.getUTCHours() + (time.getUTCMinutes() / 60);
  }

  function day_index(day) {
    switch(day) {
      case 'M':
        return 0;
      break;
      case 'T':
        return 1;
      break;
      case 'W':
        return 2;
      break;
      case 'R':
        return 3;
      break;
      case 'F':
        return 4;
      break;
      default:
        return -1;
      break;
    }    
  };

});
