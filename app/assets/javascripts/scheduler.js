$(function(){

  function draw_section( section, days ) {
    var start_time = new Date( Date.parse( section['start_time'] ) );
    va end_time   = new Date( Date.parse( section['end_time'] ) );
    var day_array = section[ 'days' ].split( "" );
    for( var i in day_array)  {
      var day_element = document.createElement("div");    
      var hour_diff = end_time.getUTCHours() - start_time.getUTCHours();
      var min_diff = (end_time.getMinutes() - start_time.getMinutes())/60;
      var width = $("tr").width();
      if( !width ) width = 149; /* HACK, need to set the description to the width */
      $(day_element).css("width", width)
                    .append($('<span/>')
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


  function init() {
    init_events();
  }

  function init_events() {
    $(".schedule-block").mouseover( function(){
      $(this).find("ul.hidden-data").fadeIn('fast');
    });

    $(".schedule-block").mouseleave( function(){
      $(this).find("ul.hidden-data").fadeOut('slow');
    });

    $(".schedule-block").mousedown( function(){
      var section = $(this).find(".hidden").text();
      get_schedule_ids( function(schedule) {
        $.ajax({
          type: 'POST',
          data: { section: section, schedule:schedule},
          url:  '/user/scheduler/move_section',
          dataType: 'json',
          success: function(data, textStatus, jqXHR ) {
            console.log("request completed successfully!");
            console.log(data);
          },
        });
      });
    });
  }

  function get_schedule_ids(callback) {
    $(".schedule-wrapper").each( function(i) {
      if( $(this).css("display") == "block" ) {
        var sections = [];
        var all_section_ids = $(this).find(".schedule-block .hidden")
        for( var i = 0; i < all_section_ids.size(); i++ ){
          var current_section_id = all_section_ids[i].innerHTML;
          if( sections.indexOf(current_section_id) == -1 ) {
            sections.push(current_section_id);
          }
        }
        callback(sections);
      }
    });
  }

  // Setup the slidejs plugin
  $("#slides").slides({
    autoHeight: true,
    generatePagination: true
  });

  function handle_drop( event, ui ) {
    ui.draggable.addClass( 'correct' );
    //ui.draggable.draggable( 'disable' );
    $(this).droppable( 'disable' );
    ui.draggable.position( { of: $(this), my: 'left top', at: 'left top' } );
    ui.draggable.draggable( 'option', 'revert', false );
  }

  function start_drag_event( event, ui ) {
    console.log(ui);
    //ui.draggable.draggable( 'option', 'revert', true );
  }

  $(".schedule-block").draggable({
    containment: '.slides_container',
    cursor:      'move',
    snap:        '.droppable',
    //start:       start_drag_event,
    revert:      true,
  });

  $(".droppable").droppable({
    accept:      '.schedule-block',
    hoverClass:  'hover',
    drop:        handle_drop
  });

  init();

});
