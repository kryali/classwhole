//var COURSE_COLORS = ["#33CCFF", "#00CC66", "#FF3333", "#FF9900", "#CC33CC", "#99FF00", "#FFFF00"];
var COURSE_COLORS = ["#E0F8FF", "#EAFFD9", "#FFDDFF", "#FFF4F2", "#ffeec9"];
var BACKGROUND_COLORS = ["#DDDDDD", "#AAAAAC", "#EEEEEE"];
var LEFT_OFFSET = 50;
var TOP_OFFSET = 30;
var BLOCK_WIDTH = 122
var BLOCK_HEIGHT = 75;
var TEXT_OFFSET = 5;
//var canvas = document.getElementById('schedule-render');

function ScheduleCanvas( canvas, sections ) { 
  this.canvas = canvas;
  this.sections = sections;
  this.init();
}

ScheduleCanvas.prototype.init = function() {
  generate_schedule_canvas( this.canvas, this.sections );
}

ScheduleCanvas.prototype.image_data = function() {
  var image_data = this.canvas.toDataURL("image/png");
  image_data = image_data.substr(image_data.indexOf(',') + 1).toString();
  return image_data;
}

/*
  init( canvas );

  function init( canvas ) {
    $(".download-schedule").click( function() {
      generate_schedule_canvas( canvas, sections );
      save_canvas( canvas );
    });
  }
*/

function generate_schedule_canvas( canvas, sections ) {
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

  canvas.width = LEFT_OFFSET + (5 * BLOCK_WIDTH) +1;
  canvas.height = TOP_OFFSET + ((end_hour-start_hour) * BLOCK_HEIGHT) +1;
  var context = canvas.getContext('2d');

  draw_background(context, start_hour, end_hour);

  // draw section shadows
  for (var i = 0; i < sections.length; i++) {
    draw_section_shadow(context, time_float(start_time) - 1, sections[i]);
  }

  // draw sections
  context.shadowOffsetX = 0;
  context.shadowOffsetY = 0;
  context.shadowBlur    = 0;
  var uniques = []
  for (var i = 0; i < sections.length; i++) {
    var section = sections[i];
    var code = section["course_subject_code"] + section["course_number"];
    if( uniques.indexOf(code) == -1 ) {
      uniques.push(code);
    }
    draw_section(context, time_float(start_time) - 1, section, COURSE_COLORS[uniques.indexOf(code)]);
  }
}


function draw_background(context, start_hour, end_hour) {
  var hours = end_hour - start_hour;
  context.font = "10pt Arial";
  context.fillStyle = "#000000";

  // draw days of week
  context.textBaseline = "middle";
  context.textAlign = "center";
  context.fillText("Monday", LEFT_OFFSET + BLOCK_WIDTH/2, TOP_OFFSET/2);
  context.fillText("Tuesday", LEFT_OFFSET + BLOCK_WIDTH + BLOCK_WIDTH/2, TOP_OFFSET/2);
  context.fillText("Wednesday", LEFT_OFFSET + 2*BLOCK_WIDTH + BLOCK_WIDTH/2, TOP_OFFSET/2);
  context.fillText("Thursday", LEFT_OFFSET + 3*BLOCK_WIDTH + BLOCK_WIDTH/2, TOP_OFFSET/2);
  context.fillText("Friday", LEFT_OFFSET + 4*BLOCK_WIDTH + BLOCK_WIDTH/2, TOP_OFFSET/2);

  // draw rectangles around days of week
  context.lineWidth = 1;
  context.strokeStyle = "#999999";
  for (var i = 0; i < 5; i++) {
    context.strokeRect(LEFT_OFFSET + i*BLOCK_WIDTH + 0.5, 0.5, BLOCK_WIDTH, TOP_OFFSET);
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
    context.fillText(display_hour.toString() + suffix, LEFT_OFFSET - 5, TOP_OFFSET + j*BLOCK_HEIGHT, LEFT_OFFSET);
  }

  // draw background blocks
  for (var i = 0; i < 5; i++) {
    for (var j = 0; j < hours; j++) {
      var x = LEFT_OFFSET + i * BLOCK_WIDTH;
      var y = TOP_OFFSET + j * BLOCK_HEIGHT;
      draw_block(context, x, y)
    }
  }
}

function draw_section(context, start_hour, section, color) {
  var start_time = new Date(section["start_time"]);
  var end_time = new Date(section["end_time"]);
  var start_position = BLOCK_HEIGHT * (time_float(start_time) - start_hour);
  var end_position = BLOCK_HEIGHT * (time_float(end_time) - start_hour);
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
    var x = LEFT_OFFSET + index * BLOCK_WIDTH;
    var y = TOP_OFFSET + start_position;
    // block
    context.fillStyle = color;
    context.fillRect(x, y, BLOCK_WIDTH, height);
    context.strokeStyle = "#666666";
    context.strokeRect(x, y, BLOCK_WIDTH, height);
    // text
    context.fillStyle = "#000000";
    context.textBaseline = "top";
    context.textAlign = "left";
    context.font = "12pt Arial";
    context.fillText(section_name, x + TEXT_OFFSET, y + TEXT_OFFSET);
    context.font = "10pt Arial";
    context.textAlign = "right";
    context.fillText(section_type, x + BLOCK_WIDTH - TEXT_OFFSET, y + TEXT_OFFSET);
    context.fillText(section_room, x + BLOCK_WIDTH - TEXT_OFFSET, y + TEXT_OFFSET + 20);
    context.textBaseline = "bottom";
    context.fillText(section_time, x + BLOCK_WIDTH - TEXT_OFFSET, TOP_OFFSET + end_position - TEXT_OFFSET);
  }
}

function draw_section_shadow(context, start_hour, section) {
  var start_time = new Date(section["start_time"]);
  var end_time = new Date(section["end_time"]);
  var start_position = BLOCK_HEIGHT * (time_float(start_time) - start_hour);
  var end_position = BLOCK_HEIGHT * (time_float(end_time) - start_hour);
  var height = end_position - start_position;

  var days = section["days"];

  for(var i = 0; i < days.length; i++) {
    var index = day_index(days.charAt(i));
    if(index == -1) { 
      continue; 
    }
    var x = LEFT_OFFSET + index * BLOCK_WIDTH;
    var y = TOP_OFFSET + start_position;
    // block
    context.shadowOffsetX = 2;
    context.shadowOffsetY = 2;
    context.shadowBlur    = 4;
    context.shadowColor   = 'rgba(0, 0, 0, 0.35)';
    context.fillStyle = "#000000";
    context.fillRect(x, y, BLOCK_WIDTH, height);
  }
}

function draw_block(context, x, y) {
  context.fillStyle = BACKGROUND_COLORS[0];
  context.fillRect(x, y, BLOCK_WIDTH, BLOCK_HEIGHT);
  context.strokeStyle = BACKGROUND_COLORS[2];
  x += 0.5;
  y += 0.5;
  context.lineWidth = 1;
  context.moveTo(x+1, y+1);
  context.lineTo(x + BLOCK_WIDTH - 2, y + 1);
  context.lineTo(x + BLOCK_WIDTH - 2, y + BLOCK_HEIGHT - 2);
  context.lineTo(x + 1, y + BLOCK_HEIGHT - 2);
  context.lineTo(x + 1, y + 1);
  context.stroke();
  context.strokeStyle = BACKGROUND_COLORS[1];
  context.strokeRect(x, y, BLOCK_WIDTH, BLOCK_HEIGHT);
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
}

function save_canvas( canvas ) {
  var image_data = canvas.toDataURL("image/png");
  image_data = image_data.substr(image_data.indexOf(',') + 1).toString();
  /*$.ajax({
    type: 'POST',
    data: { image_data:image_data },
    url:  "/scheduler/download",
    success: function(data, textStatus, jqXHR) {
      window.open(uriContent, 'neuesDokument');
      var img = $("<img/>").attr("src", "data:image/png;base64," + data );
      $("#wrapper").append(img);
    }
  });*/
  var dataInput = document.createElement("input");
      dataInput.setAttribute("name", 'image_data');
      dataInput.setAttribute("value", image_data);
  var myForm = document.createElement("form");
      myForm.method = 'post';
      myForm.action = "/scheduler/download";
      myForm.setAttribute("authenticity_token", AUTH_TOKEN );
      myForm.authenticity_token = AUTH_TOKEN;
      myForm.appendChild(dataInput);
      document.body.appendChild(myForm);
      myForm.submit();
      document.body.removeChild(myForm);
}
