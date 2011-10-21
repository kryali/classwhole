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
var schedules = [];
var schedule_obj = {};
var block_height = 80;

function time_range( schedule ) {
  var earliest_start_time = 24 * 60;
  var latest_end_time = 0;
  for( var i = 0 ; i < schedule.length; i++) {
    var section = schedule[i];
    console.log( section );
    var start_time = new Date( Date.parse( section['start_time'] ) );
    console.log( start_time.getUTCHours() );
    start_time = (start_time.getUTCHours() * 60) + start_time.getMinutes();

    var end_time   = new Date( Date.parse( section['end_time'] ) );
    end_time = (end_time.getUTCHours() * 60) + end_time.getMinutes();

    if ( start_time < earliest_start_time )
      earliest_start_time = start_time;
    if ( end_time > latest_end_time )
      latest_end_time = end_time;
  }
  
  earliest_start_time = Math.ceil( earliest_start_time/60 );
  latest_end_time = Math.ceil( latest_end_time/60 );
  return [earliest_start_time, latest_end_time]
}

function draw_all_schedules( all_schedules ) {
  schedules = new Array( all_schedules.length );
  for( var i = 0; i < all_schedules.length; i++ ) {
    schedules[i] = draw_schedule( all_schedules[i]);
  }
}

function draw_section( section, days ) {
  var start_time = new Date( Date.parse( section['start_time'] ) );
  var end_time   = new Date( Date.parse( section['end_time'] ) );
  var day_array = section[ 'days' ].split( "" );
  for( var i in day_array)  {
    var day_element = document.createElement("div");    
    var hour_diff = end_time.getUTCHours() - start_time.getUTCHours();
    var min_diff = (end_time.getMinutes() - start_time.getMinutes())/60;
    $(day_element).append($('<span/>')
                          .append(section['code'] )
                          .addClass('section-code'))
                  .append($('<span/>')
                          .append(section['course_subject_code'] + " " + section['course_number'] )
                          .addClass('course-name'))
                  .append($('<span/>')
                          .append(section['section_type'] )
                          .addClass('section-type label'));
    day_element.className = "schedule-block";
    day_element.style.top = ((start_time.getUTCHours() - DAY_START) * block_height) + "px";
    day_element.style.height = block_height * (hour_diff + min_diff) + "px";
    days[ day_array[i] ].appendChild( day_element );
  }
}

function draw_schedule( schedule) {
  container = document.createElement( 'div' );
  container.className = "schedule-wrapper";
  draw_time_labels(container, DAY_START, DAY_END);

  range = time_range( schedule );
  console.log( range );
  for( var key in days ) {
    day = document.createElement( 'table' );
    day.className = "schedule-day";
    for(var i = DAY_START; i < DAY_END; i++){
      var hour = document.createElement( 'tr' );
      day.appendChild( hour );
    }
    days[key] = day;
    container.appendChild( day );
  }

  for( var section_index in schedule ) {
    draw_section( schedule[section_index], days );
  }

  $( "#content" ).append( container );
  schedule_obj = { 'schedule': schedule, 'container': container, 'days': days };
  return schedule_obj;
}

function draw_time_labels( container, day_start, day_end ) {
  var label_list = document.createElement( 'ul' );
  label_list.className = "time-label";
  for(var i = day_start; i < day_end; i++){
    var time_item = document.createElement( 'li' );
    if( i > 12 )
      time_item.innerHTML = (i-12) + " pm";
    else if ( i == 12)
      time_item.innerHTML = i + " pm";
    else
      time_item.innerHTML = i + " am";
    label_list.appendChild(time_item);
  };
  container.appendChild(label_list);
}
