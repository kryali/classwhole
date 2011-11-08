/*
Description: This file lets you create alerts, uses twitter bootstrap

Inserts this html into the document

Example of what's getting inserted

<div class="alert-message fade in" data-alert="alert">
<a class="close" href="#">x</a>
<p><strong>Test</strong> This is a test message.</p>
</div>
 */

$(document).ready(function () {
  /* 
      Use this function to create pop up alerts in your code
      USAGE: pop_alert("warning", "This is a warning message");
        
      global right now, see if this is correct later
  */

  timeout = 1300;

 pop_alert = function(level, bold_message, message) {

    /* Build the html and insert it into the document */
    var alert_close_box = $('<a />', {
      href: "#",
      class: "close",
      text: "x"
    });
    var alert_message = $('<p />')
                            .append($("<strong/>").text(bold_message))
                            .append(message);
    var alert_box = $('<div />', { class: "alert-message " + level + " fade in"});

    alert_box.append(alert_close_box);
    alert_box.append(alert_message);
    alert_box.css("opacity", "0");
    
    /* Enable the close button on the box - Twitter bootstrap voodoo*/
    alert_box.alert();
    $('.alert-box').append(alert_box);

    alert_box.animate({
      opacity: 1,
    }, 100, undefined );

    var hide_timeout = setTimeout( function() {
                                  alert_box.animate({
                                    opacity: 0,
                                    display: 'none',
                                  }, 400, undefined );
                               }, 1000);
    var rem_timeout = setTimeout( function() { alert_box.remove(); }, timeout + 400);
  };

});
