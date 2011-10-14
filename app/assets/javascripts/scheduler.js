var MONDAY = "M";
var TUESDAY = "T";
var WEDNESDAY = "W";
var THURSDAY = "R";
var FRIDAY = "F";

var DAY_START = 8;
var DAY_END = 22;

var days = { "M": undefined,
             "T": undefined,
             "W": undefined,
             "R": undefined,
             "F": undefined }; 
var schedules =[];
var schedule_obj = {};
var block_height = 40;

function draw_all_schedules( all_schedules ) {
  schedules = new Array(all_schedules.length);
  for( var i = 0; i < 1; i++ ) {
    schedules[i] = draw_schedule( all_schedules[i] );
  }
}

function draw_section( section, days ) {
  var start_time = new Date(Date.parse(section['start_time']));
  console.log( section['start_time'] );
  console.log( start_time );
  var day_array = section['days'].split("");
  for( var i in day_array)  {
    var day_element = document.createElement("li");    
    day_element.innerHTML = section['code'];
    day_element.className = "schedule-block";
    day_element.style.top = (((DAY_START+1)- start_time.getHours()) * block_height) + "px";
    days[day_array[i]].appendChild(day_element);
  }
}

function draw_schedule( schedule ) {
  console.log( schedule );
  container = document.createElement('div');
  container.className = "schedule-wrapper";
  for( var key in days ) {
    day = document.createElement('div');
    day.className = "schedule-day";
    days[key] = day;
    container.appendChild(day);
  }

  for( var section_index in schedule ) {
    draw_section( schedule[section_index], days );
  }

  $("#content").append(container);
  schedule_obj = { 'schedule': schedule, 'container': container, 'days': days };
  return schedule_obj;
}
