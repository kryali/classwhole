$(function(){
  
  //var block_height = 74;
  var block_height = $(".schedule-block").height();
  var is_dragging = false;
  var is_showing_hints = false;
  var is_updating = false;
  var handled_drop = false;
  var save_schedule_path = "/scheduler/save";
  var share_schedule_path = "/scheduler/share";
  var paginate_path = "/scheduler/paginate";
  var sidebar_path = "/scheduler/sidebar";
  var current_selected = 1;
  var mini_grids_showing = 5;
  var mini_grids_count = 5;

  var hint_cache = {};
  var section_cache = {};
  var schedule_cache = {};
  var schedule_raw_cache = {};

  var options = {
    draggable: {
      snap:        '.ui-droppable',
      snapMode:    'inner',
      snapTolerance: 20,
      start:       start_drag_event,
      stop:        stop_drag_event,
      revert:      true,
      revertDuration: 200,
      scope:        'section_hint',
      refreshPositions: true,
      zIndex:       1100,
    },
    droppable: {
      accept:      '.ui-draggable',
      hoverClass:  'hover',
      drop:        handle_drop,
      scope:        'section_hint',
    },
    slides: {
      autoHeight: true,
      pagination: true,
      paginationClass: 'mini-pagination',
      generatePagination: false,
    }
  }

  function save_schedule() {
    var schedule_ids = get_schedule_ids();
    $.ajax({
      type: 'POST',
      data: { schedule:schedule_ids},
      url:  save_schedule_path,
      success: function(data, textStatus, jqXHR) {
        if (data["status"] == "success") {
          mpq.track("Save schedule");
          pop_alert("info", data["message"]);
          /* Redirect them
          if( data.redirect_url && window.loaction != data.redirect_url)
            window.location = data.redirect_url;
            */
        }
        else if (data["status"] == "error") {
          //pop_alert("error", data["message"]);
          showModal('/scheduler/_need_to_login',{"name": "save"});
          mpq.track("Prompt log in");
          $(document).bind('logged-in', function() {
            $(document).unbind('logged-in');
            hideModal();
            save_schedule();
            return true;
          });
        }          
      }
    });
  }

  function init_tooltips() {
    $(".register-schedule").tipsy({ gravity: 'n', opacity: .9});
    //$(".download").tipsy({ gravity: 's' });
    $(".share-schedule").tipsy({ gravity: 's', opacity: .9});
    //$(".save").tipsy({ gravity: 's' });
    var options = { 
      trigger: 'manual',
      gravity: 'e',
      fade: true,
      title: 'data-tooltip',
    };
    // Display a welcome message to a temporary user
    if( $("#current_user").text() == "" ) {
      $(".schedule-content").tipsy(options);
      setTimeout( function() {
        $(".schedule-content").tipsy("show");
        setTimeout( function() {
          $(".schedule-content").tipsy("hide");
        }, 2500 );
      }, 2500 );
    }
  }

  /* This is kind of a hack
      
      We need to get a json array of sections to hand to Jon's canvas
      but that's not given to us in the page, so I request it via AJAX 
      to the server instead.
   */
  function init_download_schedule() {
    var canvas = document.getElementById('schedule-render');
    $(".download").click( function() {
      var schedule_ids = get_schedule_ids();

      // temp hack, get sections json with given section ids via ajax
      $.ajax( {
        type: 'POST',
        url: '/sections/',
        data: { schedule: schedule_ids },
        success: function( data, textStatus, xhQR) {
          if( data.status == "success" ) {
            mpq.track("Schedule Downloaded");
            var schedule_canvas = new ScheduleCanvas( canvas, data.sections );
            start_download( schedule_canvas.image_data() );
          }
        }
      });
    });
  }

  function start_download( image_data ) {
    var myForm = document.createElement("form");
        myForm.setAttribute("method", "post" );
        myForm.setAttribute("action", "/scheduler/download" );
        myForm.setAttribute("authenticity_token", AUTH_TOKEN);
    var auth_token = document.createElement("input");
        auth_token.setAttribute("name", "authenticity_token");
        auth_token.setAttribute("type", "hidden");
        auth_token.setAttribute("value", AUTH_TOKEN);
        myForm.appendChild(auth_token);
    var dataInput = document.createElement("input");
        dataInput.setAttribute("type", "hidden");
        dataInput.setAttribute("name", "image_data");
        dataInput.setAttribute("value", image_data);
        dataInput.setAttribute("authenticity_token", AUTH_TOKEN);
        myForm.appendChild(dataInput);
        document.body.appendChild(myForm);
        myForm.submit();
  }

  function init_modals() {
    $(".save").unbind('click').click( function() {
      save_schedule();
    });

    $(".register-schedule").unbind('click').click( function() {
      mpq.track("Register schedule");
      $('#crns').empty()
      var schedule = get_current_schedule();
      var crns = [];
      var all_section_crns = schedule.find(".schedule-block .crn");
      for( var i = 0; i < all_section_crns.size(); i++ ){
        
        // Ignore droppable sections
        if (!$(all_section_crns[i]).parent().hasClass("ui-droppable")) {
          var current_section_crn = all_section_crns[i].innerHTML;

          // Make sure we don't already have the section in our array
          if( crns.indexOf(current_section_crn) == -1 ) {
            crns.push(current_section_crn)
            //$('#crns').append("<li>" + current_section_crn + "</li>");
          }
        }
      }
      //console.log(crns.toString());
      window.location = "/scheduler/register?crns=" + crns.toString();
    });
  }

  function share_schedule() {
    var schedule_ids = get_schedule_ids();
    $.ajax({
      type: 'POST',
      data: { schedule: schedule_ids },
      url: share_schedule_path,
      success: function(data, textStatus, jqXHR) {
        if (data["status"] == "success") {
          //console.log(data);
          //pop_alert("info", data["message"]);
          mpq.track("Share schedule");
          FB.ui(data.options, function(response) {
            if( response && response.post_id ) {
              pop_alert("success", "Schedule shared!");
            } else {
              pop_alert("error", "Sharing failed :(");
            }
          });
        }
        else if (data["status"] == "error") {
          //pop_alert("error", data["message"]);
          showModal('/scheduler/_need_to_login',{"name": "share"});
          mpq.track("Prompt log in");
          $(document).bind('logged-in', function() {
            $(document).unbind('logged-in');
            hideModal(); 
            share_schedule();
            return true;
          });
        }
      }
    });
  }

  function init_share_button() {
    // Share facebook
    $(".share-schedule").click( function() {
      share_schedule();
    });
  }
  function init_pagination() {
    $(".mini-pagination a").click( function() {

      // Set as the current item
      $(".mini-pagination .current").removeClass("current");
      $(this).parent().addClass("current");

      // Decode the index from the href i.e "#1" -> 1
      var index = parseInt($(this).attr("href").replace(/#/g,""));
      var schedule_ids = possible_schedules[index]; // Global given to us in the view

      // Update main page
      $.ajax({
        type: 'POST',
        data: { schedule:schedule_ids, render: true },
        url:  '/scheduler/move_section',
        success: function(data, textStatus, jqXHR) {
          //curr_section.draggable( "option", "revert", "false" );
          fetch_schedule(data, textStatus, jqXHR, undefined);
          is_showing_hints = false;
        }
      });

      // Update sidebar
      $.ajax({
        type: 'POST',
        data: { schedule:schedule_ids },
        url:  sidebar_path,
        success: function(data, textStatus, jqXHR) {
          var contents = $(data).children();
          $("ul.courses").empty().append(contents);
          init_fb();
        }
      });
    });
  }

  init = function() {
    // Setup the slidejs plugin
    //$("#slides").slides(options.slides);

    // Hide tooltips if they are a user
    if( $("#current_user").text() == "" ) {
      init_tooltips();
    }
    init_draggable();
    init_modals();
    init_share_button();
    init_download_schedule();
    init_pagination();

    //init_mini_pagination();

    // Use the keyboard to select other schedules
    $(document).keydown( function(event) {
        var keycode = $.ui.keyCode;
        if( event.keyCode == keycode.LEFT ) {
          $(".prev").click();
          event.preventDefault();
        } else if( event.keyCode == keycode.RIGHT) {
          $(".next").click();
          event.preventDefault();
        }
    });

    // TODO: BUG IF YOU CLICK TOO FAST
    $(".prev").click( function() {
      mpq.track("Clicked left arrow");
      if( current_selected > 1 )
        current_selected--;
      else {
        $(".mini-prev").click();
        current_selected = mini_grids_showing;
      }
    });

    $(".next").click( function() {
      mpq.track("Clicked right arrow");
      current_selected++;
      if( current_selected > mini_grids_showing ){
        $(".mini-next").click();
        current_selected = 1;
      }
    });

    var children = $(".mini-pagination").children();
    $('.mini-pagination').css("width", children.width() * children.length + 30);
  }

  function init_mini_pagination() {
    var width = $(".mini-pagination-container").width() + 1;
    var mini_pagination = $(".mini-pagination");
    var children = $(".mini-pagination").children();
    var start = 0;
    var end = mini_grids_showing;

    mini_pagination.css("width", children.width() * children.length);

    $(".mini-prev").click( function() {
      var current_pos = mini_pagination.position().left;
      // Make sure it's not already the the most left
      if( current_pos != 0) {
        end = start;
        start -= mini_grids_showing;
        mini_pagination.animate({ left: current_pos + width + "px"}, 250, undefined);
      }
    });

    $(".mini-next").click( function() {
      var current_pos = mini_pagination.position().left;
      if( end <= mini_grids_count) {
        //console.log("starting a request");
        $.ajax({
          type: 'POST',
          url: paginate_path,
          data: { 
            courses: course_ids, 
            start: start, 
            end: end,
          },
          success: function(data, textStatus, jqXHR) {
            var full = $(data).first();
            var mini = $(data).last();
            $(".slides_control").append( full.children() );
            mini_pagination.append( mini.children() );

            var children = mini_pagination.children();
            mini_pagination.css("width", children.width() * children.length);
            mini_pagination.animate({ left: current_pos - width + "px"}, 250, undefined);
            $("#slides").slides(options.slides);
          }
        });
      } else {
        start = end;
        end = end + mini_grids_showing;
        mini_grids_count += mini_grids_showing;
        mini_pagination.animate({ left: current_pos - width + "px"}, 250, undefined);
      }
    });
  }

  function init_draggable() {
    $(".schedule-block:not(.ui-droppable)").draggable(options.draggable);
    $(".schedule-block:not(.ui-droppable)").mouseover( function(){
      if( is_showing_hints ) return;
      is_showing_hints = true;

      var current_section = $(this);
      current_section.draggable( 'option', 'revert', true );
      var section_id = current_section.find(".id").text();
      var schedule_ids = get_schedule_ids();
      //console.log( "Selected" + section );
      //console.log( schedule_ids );
      update_schedule( section_id, schedule_ids );
    });
    
    $(".schedule-block:not(.ui-droppable)").mouseleave( function(){
      // Sometimes a mouseleave gets fired when a user is dragging
      if( is_dragging) { return; }
      is_showing_hints = false;
      $(".droppable").stop().fadeOut( 200, function() {
        $(this).remove();
      });
    });

    // Hide the course titles if the block is too small
    $(".schedule-block").each( function() {
      //if( $(this).height() < 50 ) {
        $(this).find(".course-title").hide();
      //}
    });
  }


  /* 
  This function removes a section from a day selector
   */
  remove_section_from_day = function( day, section_id) {
    var schedule_blocks = day.find(".schedule-block");
    for( var i = 0; i < schedule_blocks.length; i++) {
      var current_section =  $(schedule_blocks[i]);
      var current_section_id = current_section.find(".id").text();
      if (  section_id  == current_section_id ) {
        current_section.remove();
      }
    }
  }

  /* 
    Update schedule refreshes the schedule content with the new schedule
      from the server. It's an AJAX `success` callback function 

    This function also caches the sections and schedules w/hints
  */
  function fetch_schedule(data, textStatus, jqXHR, day, section_id, schedule_ids) {
    //console.log( data);
    // Cache sections for fun
    for( i in data.schedule ) {
      var section = data.schedule[i];
      section_cache[ section.id ] = section;
    }
    for( i in data.section_hints ) {
      var section = data.section_hints[i];
      section_cache[ section.id ] = section;
    }

    if( data.status == "error" ) {
      if( typeof schedule_ids != "undefined" ) {
        // Cache 
        var schedule_key = schedule_ids.toString();
        if( typeof schedule_cache[ schedule_key ] == "undefined" )
          schedule_cache[ schedule_key ] = {};
        schedule_cache[ schedule_key ][ section_id ] = "none";
      }
      return;
    }

    // Make sure we aren't updating the schedule when another update is in progress
    if( is_updating ) return;

    // This happens when the user stops hovering before the schedule is updated
    //if( !is_showing_hints ) return; 
    is_updating = true;

    var new_schedule = new Schedule( data.schedule, data.start_hour, data.end_hour );
    new_schedule.add_hints( data.section_hints );
    var contents = new_schedule.render().children();
    //console.log( new_schedule );

    if( typeof schedule_ids != "undefined" ) {
      // Cache 
      var schedule_key = schedule_ids.toString();
      if( typeof schedule_cache[ schedule_key ] == "undefined" )
        schedule_cache[ schedule_key ] = {};
      schedule_cache[ schedule_key ][ section_id ] = contents.clone();

      schedule_raw_cache[ schedule_key ] = data;
    }

    //var contents = $(data).children();
    var current_schedule = get_current_schedule();

    var selected_box = $(".ui-draggable-dragging");
    var selected_section_id = selected_box.find(".id").text();

    // If we aren't given a position to insert the selected box, don't add 
    if( day ){
      // Move the dragndrop to an element on the page to keep it in the document
      $("#slides").append(selected_box);

      // Add the content to the page
      update_schedule_contents( current_schedule, contents );

      // Find the day of the section we're trying to add
      var current_day = current_schedule.find("." + day );

      // Remove the duplicate section given to us by the server (selected section)
      remove_section_from_day( current_day, selected_section_id);

      // Re-insert the dragndrop to the page
      current_day.append(selected_box);
    } 
    else {
      if( selected_box.length > 0) {
        //console.log("REMOVING LAME BOX");
        selected_box.draggable("destroy");
        selected_box.remove();
      }
      //console.log( contents );
      update_schedule_contents( current_schedule, contents );
    }


  }

  function re_init( current_schedule ) {
    // Make the hints droppable
    var section_hints = current_schedule.find(".droppable").find(".schedule-block");
    section_hints.droppable(options.droppable);

    // Make the hints undraggable
    section_hints.draggable( 'disable' );
    section_hints.css( "cursor","pointer" );

    // Adjust the height of the slides window to contain the new schedule
    var new_height = current_schedule.height();
    $('.slides_control').height( new_height );

    // Make the schedule blocks fade in
    current_schedule.find(".droppable").addClass("hidden");
    current_schedule.find(".droppable").fadeIn(350);

    // Enable the new sections to be draggable
    init_draggable();
    //init_modals();
    //init_share_button();
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

  // scan through the currently selected schedule and build all the section ids
  function get_schedule_ids() {
    var schedule = get_current_schedule();
    var sections = [];
    var all_section_ids = $("ul.sections .id");
    for( var i = 0; i < all_section_ids.size(); i++ ){
      
      // Ignore droppable sections
      if (!$(all_section_ids[i]).parent().hasClass("ui-droppable")) {
        var current_section_id = all_section_ids[i].innerHTML;

        // Make sure we don't already have the section in our array
        if( sections.indexOf(parseInt(current_section_id)) == -1 ) {
          sections.push(parseInt(current_section_id));
        }
      }
    }
    return sections.sort();
  }


  function update_sidebar_contents( old_section_id, new_section_id ) {
    var current_schedule = get_current_schedule();
    var sidebar = new Sidebar();
    var section = section_cache[ new_section_id ];
    //console.log( section );
    var row = sidebar.render_section_row( section );

    current_schedule.find("ul.sections li div").each( function() {
      // Find the section row to replace
      if( $(this).find(".id").text() == old_section_id ) {
        $(this).empty().append( row.children() );
      }
    });
  }


  function handle_drop( event, ui ) {

    // Find the section that the user is holding 
    var curr_section =  $(ui.draggable[0]);
    var curr_section_id = parseInt(curr_section.find(".id").text());
    var new_section_id = parseInt($(this).find(".id").text());
    var schedule_ids = get_schedule_ids();

    // Make sure that both sections are compatible types 
    if( $(this).find(".section-type").text() != curr_section.find(".section-type").text()   
        || $(this).find(".course-name").text() != curr_section.find(".course-name").text() ) {
      return;
    }

    mpq.track("Moved Schedule");

    update_sidebar_contents( curr_section_id, new_section_id );

    // Generate the list of the new schedule to render
    var idx = schedule_ids.indexOf(curr_section_id);
    if (idx!=-1) schedule_ids.splice(idx,1);
    schedule_ids.push(new_section_id);
    schedule_ids.sort();

    //console.log(ui.draggable);
    ui.draggable.addClass( 'correct' );
    ui.draggable.draggable( 'disable' );
    $(this).droppable( 'disable' );
    ui.draggable.position( { of: $(this), my: 'left top', at: 'left top' } );
    ui.draggable.draggable( 'option', 'revert', false );
    ui.draggable.remove();

    //console.log( "selected: " + curr_section_id );
    //console.log( schedule_ids );

    $.ajax({
      type: 'POST',
      data: { schedule:schedule_ids, render: true },
      url:  '/scheduler/move_section',
      success: function(data, textStatus, jqXHR) {
        //curr_section.draggable( "option", "revert", "false" );
        fetch_schedule(data, textStatus, jqXHR, undefined);
        is_showing_hints = false;
      }
    });


  }

  function start_drag_event( event, ui ) {

    if( is_dragging) return;
    is_dragging = true;
    if( is_showing_hints) return;
    //console.log(ui);
    //console.log(event);
    var current_section = $(ui.helper[0]);
    current_section.draggable( 'option', 'revert', true );
    var section = current_section.find(".id").text();
    var schedule_ids = get_schedule_ids();
    //console.log( "requesting hints" );
    //console.log( section );
    //console.log( schedule_ids );
    $.ajax({
      type: 'POST',
      data: { section: section, schedule:schedule_ids },
      url:  '/scheduler/move_section',
      success: function(data, textStatus, jqXHR) {
        var day = $(ui.helper[0]).parent().attr("day");
        fetch_schedule(data, textStatus, jqXHR, day);
      }
    });
  }

  /*
     This function checks to see if the hint is in the cache
     If so, then it re-renders the schedule with the cache
      
     or it queries the server
  */
  function update_schedule( section_id, schedule_ids ) {
    var key = schedule_ids.toString();
    if( typeof schedule_cache[key] != "undefined"
        && schedule_cache[key][section_id] ) {

      if( schedule_cache[key][section_id] == "none" ) {
        /* cache hit: there are no possibilities */
        return;
      }
      var current_schedule = get_current_schedule();
      var contents = schedule_cache[key][section_id].clone();
      update_schedule_contents( current_schedule, contents );
      return;
    }

    $.ajax({
      type: 'POST',
      data: { section: section_id, schedule:schedule_ids },
      url:  '/scheduler/move_section',
      success: function(data, textStatus, jqXHR) {
        fetch_schedule(data, textStatus, jqXHR, undefined, section_id, schedule_ids);
      }
    });
  }

  function update_schedule_contents( current_schedule, contents ) {
    // Add the content to the page
    current_schedule.find(".schedule-day").remove();
    current_schedule.find(".time-label").remove();
    current_schedule.find(".schedule-display").prepend( contents );

    re_init( current_schedule );
    is_updating = false;
    is_dragging = false;
  }

  function stop_drag_event( event, ui ) {
    is_dragging = false;
    var droppable_timeout = 220;

    $(".droppable").stop().fadeOut( droppable_timeout, function() {
      $(this).remove();
      is_showing_hints = false;
    });

  }

});
