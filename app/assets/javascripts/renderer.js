$(function(){
  var example = document.getElementById('schedule-render');
  example.width = 1000;
  example.height = 1000;
  var context = example.getContext('2d');
  var course_colors = ["#E0F8FF", "#EAFFD9", "FFF2FF", "FFF4F2", "F3FBA2", "#F0C4F0"];
  var background_colors = ["#DDDDDD", "#AAAAAC", "EEEEEE"];
  
  var left_offset = 50;
  var top_offset = 50;
  var block_width = 122
  var block_height = 48;

  draw_background(7, 21);
  for (var i = 0; i < sections.length; i++) {
    draw_section(sections[i], course_colors[i]);
  }

  function draw_background(start_hour, end_hour) {
    var hours = end_hour - start_hour;
    context.font = "12pt Arial";
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

  function draw_section(section, color) {
    context.textBaseline = "top";
    context.textAlign = "left";
    var start_time = new Date(section["start_time"]);
    var end_time = new Date(section["end_time"]);
    var start = float_time(start_time);
    var end = float_time(end_time);
    section_start = block_height * start;
    section_height = block_height * (end - start); 
    var days = section["days"];

    var section_name = section["course_subject_code"] + " " + section["course_number"];
    var section_type = section["section_type"];
    var section_time = string_time(start_time) + " - " + string_time(end_time);

    for(var i = 0; i < days.length; i++) {
      var index = day_index(days.charAt(i));
      if(index == -1) { 
        continue; 
      }
      var x = left_offset + index * block_width;
      var y = top_offset + section_start;
      // block
      context.fillStyle = color;
      context.fillRect(x, y, block_width, section_height);
      context.fillStyle = "black";
      context.strokeRect(x, y, block_width, section_height);
      // text
      context.fillText(section_name, x, y);
      context.fillText(section_type, x, y + 15);
      context.fillText(section_time, x, y + 30);
    }
  }
  
  function string_time(time) {
    return time.toLocaleTimeString();
  }

  function float_time(time) {
    return time.getHours() + (time.getMinutes() / 60);
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
