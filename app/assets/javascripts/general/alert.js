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
  */

  var pop_alert = function(level, message) {

    /* Build the html and insert it into the document */
    var alert_close_box = $('<a />', {
      href: "#",
      class: "close",
      text: "x"
    });
    var alert_message = $('<p />', { text: message });
    var alert_box = $('<div />', { class: "alert-message " + level + " fade in"});

    alert_box.append(alert_close_box);
    alert_box.append(alert_message);
    
    /* Enable the close button on the box - Twitter bootstrap voodoo*/
    alert_box.alert();

    $('body').prepend(alert_box);
  }
});
