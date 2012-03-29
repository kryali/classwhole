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

    var container = $(".alert-box").css("display","block");
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
    }, 500, undefined );

    var remove_box = function() {
      alert_box.animate({
        opacity: 0,
      }, 400, 
      function() { 
        alert_box.remove();
        container.css("display","none");
      });
    };

    var hide_timeout = setTimeout( function() { remove_box(); }, 2400);
    alert_close_box.click( function() { remove_box(); });
  };

});
