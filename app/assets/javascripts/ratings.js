$(document).ready( function() {
  init_ratings();
});
var init_ratings = function() {
  $(".rating, .small-rating").each( function() {
    var value = parseFloat($(this).attr("data-value"));
    var total_width = $(this).find(".stars").width();
    var new_width = (value/5.0) * total_width;
    $(this).find(".fg").width( new_width );
  });
}
