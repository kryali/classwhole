$(function(){

  function handle_drop( event, ui ) {
    console.log("DROP TRIGGERED");
    ui.draggable.addClass( 'correct' );
    //ui.draggable.draggable( 'disable' );
    $(this).droppable( 'disable' );
    ui.draggable.position( { of: $(this), my: 'left top', at: 'left top' } );
    ui.draggable.draggable( 'option', 'revert', false );
    setTimeout(function() {
      ui.draggable.draggable( 'option', 'revert', true );
    }, 100);
  }

  function start_drag_event( event, ui ) {
    console.log(ui);
    //ui.draggable.draggable( 'option', 'revert', true );
  }

  // Setup the slidejs plugin
  $("#slides").slides({
    autoHeight: true,
    generatePagination: true
  });

  $(".schedule-block").mouseover( function(){
    $(this).find("ul.hidden-data").fadeIn('fast');
  });

  $(".schedule-block").mouseleave( function(){
    $(this).find("ul.hidden-data").fadeOut('slow');
  });

  $(".schedule-block").mousedown( function(){
    console.log("this is where I should start the ajax request");
    $.ajax({
      //type: 'POST',
      type: 'GET',
      url:  '/',
      dataType: 'json',
      success: function(data, textStatus, jqXHR ) {
        console.log("request completed successfully!");
        console.log(data);
      },
    });
  });

  $(".schedule-block").draggable({
    containment: '.slides_container',
    cursor:      'move',
    snap:        '.droppable',
    start:       start_drag_event,
    revert:      true,
  });

  $(".droppable").droppable({
    accept:      '.schedule-block',
    hoverClass:  'hover',
    drop:        handle_drop
  });

});
