$(document).ready( function() {
  $(".rating").each( function() {
    var value = parseFloat($(this).attr("data-value"));
    var total_width = $(this).width();
    var new_width = (value/5.0) * total_width;
    $(this).find(".fg").width( new_width );
  });
});
