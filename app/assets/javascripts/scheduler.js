$(function(){

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

});
