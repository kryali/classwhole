$(function(){

  var block_height = 74;
  var added_hours = false;

  function init() {
    init_events();
  }

  function init_events() {
    $(".schedule-block").mouseover( function(){
      //$(this).find("ul.hidden-data").fadeIn('fast');
    });

    $(".schedule-block").mouseleave( function(){
      //$(this).find("ul.hidden-data").fadeOut('slow');
    });
  }

  function add_hours( num_hours ){
    var schedule = get_current_schedule();
    schedule.each( function() {
      var schedule_day = $(this).find(".schedule-day");
      var add_list = "";
      for( var i = 0; i < num_hours; i++) {
        add_list += "<li></li>";
      }
      schedule_day.append(add_list);
      //console.log(schedule_day);
      var current_height = $(".slides_control").height();
      $(".slides_control").height(current_height + block_height * num_hours);
    });
  }

  function insert_suggestions(data, textStatus, jqXHR) {
    var schedule = get_current_schedule();
    $(data).each( function() {
      var days_s = $(this).attr("days");
      if( typeof(days_s) != "undefined" ) {
        var days_a = days_s.split("");
        for( var i = 0; i < days_a.length; i++) {
          var schedule_day = schedule.find("." + days_a[i]);
          $(this).addClass("droppable");
          var section_hint = $(this).clone().addClass("droppable");
          section_hint.droppable({
              accept:      '.schedule-block',
              hoverClass:  'hover',
              drop:        handle_drop
          });
          schedule_day.append(section_hint);
        }
      }
    });
  }

  function get_current_schedule() {
    var schedules = $(".schedule-wrapper");
    for( var j = 0; j < schedules.size(); j++) {
      var current = $(schedules[j]);
      if( current.css("display") == "block" ) {
        return current;
      }
    }
  }

  function get_schedule_ids() {
    var schedule = get_current_schedule();
    var sections = [];
    var all_section_ids = schedule.find(".schedule-block .hidden");
    for( var i = 0; i < all_section_ids.size(); i++ ){
      var current_section_id = all_section_ids[i].innerHTML;
      if( sections.indexOf(current_section_id) == -1 ) {
        sections.push(current_section_id);
      }
    }
    return sections;
  }

  // Setup the slidejs plugin
  $("#slides").slides({
    autoHeight: true,
    generatePagination: true
  });

  function remove_droppable( section_id ) { 
    $(".schedule-block").each( function() {
      var current_id = $(this).find(".hidden").text(); 
      if( current_id == section_id ) {
        $(this).removeClass("droppable");
      }
    });
  }
  /* This function removes sections with a given section id */
  function remove_section( section_id ) {
    get_current_schedule().find(".schedule-block").each( function() {
      var current_id = $(this).find(".hidden").text(); 
      if( current_id == section_id ) {
        $(this).remove();
      }
    });
  }

  function handle_drop( event, ui ) {
    var current_course =  $(ui.draggable[0]);
    remove_section( current_course.find(".hidden").text() );
    remove_droppable( $(this).find(".hidden").text() );
    current_course.remove();
    //ui.draggable.draggable( 'disable' );
    $(this).removeClass("droppable");
    ui.draggable.addClass( 'correct' );
    $(this).droppable( 'disable' );
    ui.draggable.position( { of: $(this), my: 'left top', at: 'left top' } );
    ui.draggable.draggable( 'option', 'revert', false );

    $(this).draggable({
      snap:        '.droppable',
      start:       start_drag_event,
      stop:        stop_drag_event,
      revert:      true,
    });

    stop_drag_event( undefined, undefined );
  }

  function start_drag_event( event, ui ) {
    if( !added_hours ) { 
      add_hours(4);
      added_hours = true;
    }
    var current_section = $(ui.helper[0]);
    current_section.draggable( 'option', 'revert', true );
    var section = current_section.find(".hidden").text();
    var schedule_ids = get_schedule_ids();
    console.log(schedule_ids);
    $.ajax({
      type: 'POST',
      data: { section: section, schedule:schedule_ids},
      url:  '/scheduler/move_section',
      success: insert_suggestions,
    });
  }

  function stop_drag_event( event, ui ) {
    console.log("Removing droppables");
    $('.droppable').remove();
  }

  $(".schedule-block").draggable({
    snap:        '.droppable',
    start:       start_drag_event,
    stop:        stop_drag_event,
    revert:      true,
  });

  init();

});
