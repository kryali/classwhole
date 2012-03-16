$(document).ready(function() {

  function hide_dropdown() {
    $(".dropdown-menu").css("display", "none");
  }

  function show_dropdown() {
    $(".dropdown-menu").css("display", "block");
  }

  $(".dropdown").bind('mouseover', show_dropdown );
  $(".dropdown").bind('mouseleave', hide_dropdown );
  $(".dropdown-menu").bind("mouseleave", hide_dropdown );

});
