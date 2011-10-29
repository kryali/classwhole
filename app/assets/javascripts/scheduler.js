$(function(){

  var block_height = 74;

  function init() {

    // Setup the slidejs plugin
    $("#slides").slides({
      autoHeight: true,
      generatePagination: true
    });

    // Additional menus on hover over
    $(".schedule-block").mouseover( function(){
      //$(this).find("ul.hidden-data").fadeIn('fast');
    });
    $(".schedule-block").mouseleave( function(){
      //$(this).find("ul.hidden-data").fadeOut('slow');
    });

    init_draggable();

  }

  function init_draggable() {
    $(".schedule-block").draggable({
      snap:        '.droppable',
      start:       start_drag_event,
      stop:        stop_drag_event,
      revert:      true
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

  function move_element(element, selector, target) {
    var children = element.children();

    if ( children.length == 0 ) {
      return;
    }
    for( var i = 0; i < children.length; i++) {
      if( children[i].className.indexOf(selector) == -1 ) {
        move_element( $(children[i]), selector, target );
      } else {
        target.append($(children[i]));
        console.log(target);
        $(children[i]).remove();
        return;
      }
    }
    return;
  }

  function get_section_id( section ) {
    return section.find("hidden").text()
  }

  /* 

  This function removes a section from a day selector
    
   */
  remove_section_from_day = function( day, section_id) {
    var schedule_blocks = day.find(".schedule-block");
    for( var i = 0; i < schedule_blocks.length; i++) {
      var current_section =  $(schedule_blocks[i]);
      var current_section_id = current_section.find(".hidden").text();
      if (  section_id  == current_section_id ) {
        current_section.remove();
      }
    }
  }

  /* 
    Update schedule refreshes the schedule content with the new schedule
      from the server. It's an AJAX `success` callback function */
  function update_schedule(data, textStatus, jqXHR, day) {
    var contents = $(data).children();
    var current_schedule = get_current_schedule();

    var selected_box = $(".ui-draggable-dragging");
    var selected_section_id = selected_box.find(".hidden").text();
    
    // Move the dragndrop to an element on the page to keep it in the document
    $("#slides").append(selected_box);

    // Add the content to the page
    current_schedule.empty().append(data);

    // Find the day of the section we're trying to add
    var current_day = current_schedule.find("." + day );

    // Remove the duplicate section given to us by the server (selected section)
    remove_section_from_day( current_day, selected_section_id);
  
    if( !day ){
      selected_box.draggable("destroy");
      console.log("Destroyed box, go away!!");
      selected_box.remove();
    }

    // Re-insert the dragndrop to the page
    current_day.append(selected_box);

    // Enable the new sections to be draggable
    init_draggable();

    // Make the hints droppable
    var section_hints = current_day.find(".droppable").find(".schedule-block")
    section_hints.droppable({
        accept:      '.schedule-block',
        hoverClass:  'hover',
        drop:        handle_drop
    });

    // Make the hints undraggable
    $(".droppable").find(".schedule-block").draggable( 'disable' );
    //section_hints.draggable( 'disable' );
    section_hints.css( "cursor","pointer" );

    var new_height = current_schedule.height();
    $('.slides_control').height( new_height );

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

  /* Unhide the new sections */
  function setup_new_sections( section_id ) {
    get_current_schedule().find(".droppable").each( function() {
      if( $(this).find(".hidden").text() == section_id ){

        // Enable draggable for new sections
        $(this).find(".schedule-block").draggable( 'enable' );
        $(this).find(".schedule-block").removeClass("ui-droppable");

        // Disable droppable for new sections
        $(this).removeClass("droppable");
      };
    });
  }

  function handle_drop( event, ui ) {
    // Find the section that the user is holding 
    var curr_section =  $(ui.draggable[0]);
    var curr_section_id = curr_section.find(".hidden").text();
    var new_section_id = $(this).find(".hidden").text();
    var schedule_ids = get_schedule_ids();

    var idx = schedule_ids.indexOf(curr_section_id);
    if (idx!=-1) schedule_ids.splice(idx,1);
    schedule_ids.push(new_section_id);

    $.ajax({
      type: 'POST',
      data: { schedule:schedule_ids},
      url:  '/scheduler/move_section',
      success: function(data, textStatus, jqXHR) {
        ///var day = $(ui.helper[0]).parent().attr("day");
        update_schedule(data, textStatus, jqXHR, undefined);
      }
    });
    /*
    // Remove those sections from the view
    remove_section( curr_section_id );
    setup_new_sections( new_section_id );

    // Clean up
    stop_drag_event( undefined, undefined );
    */
  }

  function start_drag_event( event, ui ) {
    //console.log(ui);
    //console.log(event);
    var current_section = $(ui.helper[0]);
    current_section.draggable( 'option', 'revert', true );
    var section = current_section.find(".hidden").text();
    var schedule_ids = get_schedule_ids();
    //console.log(schedule_ids);
    console.log( section );
    console.log( schedule_ids );
    $.ajax({
      type: 'POST',
      data: { section: section, schedule:schedule_ids},
      url:  '/scheduler/move_section',
      success: function(data, textStatus, jqXHR) {
        var day = $(ui.helper[0]).parent().attr("day");
        update_schedule(data, textStatus, jqXHR, day);
      }
    });
  }

  function stop_drag_event( event, ui ) {
    console.log("Removing droppables");
    $('.droppable').remove();
  }

  init();

});
