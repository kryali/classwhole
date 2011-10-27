$(function(){

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
      $.ajax({
        type: 'POST',
        data: { section:1, schedule:[1,2,3], 'test':'fuck cliff in the face'},
        url:  '/user/scheduler/move_section',
        dataType: 'json',
        success: function(data, textStatus, jqXHR ) {
          console.log("request completed successfully!");
          console.log(data);
        },
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
  get_schedule_ids( function(schedule) { 
    console.log(schedule);
    console.log(schedule[0]);

    $.ajax({
      type: 'POST',
      data: { section: schedule[0], schedule: schedule},
      url:  '/user/scheduler/move_section',
      dataType: 'json',
      success: function(data, textStatus, jqXHR ) {
        console.log("request completed successfully!");
        console.log(data);
      },
    });

  });

});
