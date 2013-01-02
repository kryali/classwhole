// TODO: turn into directive
$(document).ready(function (){
  var emails = $(".to-reverse");
  emails.each( function() {
    var cur_email = $(this);
    var text = $(this).text().split("").reverse().join("");
    var a = $("<a/>").attr("href", "mailto:" + text )
                     .text( text );
    cur_email.empty().append(a);
  });
});
