$(function(){
  var example = document.getElementById('schedule-render');
  example.width = 1000;
  example.height = 1000;
  var context = example.getContext('2d');
  var course_colors = ["#E0F8FF", "#EAFFD9", "FFF2FF", "FFF4F2", "F3FBA2", "#F0C4F0"];
  var background_colors = ["#DDDDDD", "#AAAAAC", "EEEEEE"];
  
  var left_offset = 50;
  var top_offset = 50;
  var block_width = 122
  var block_height = 48;

  draw_background(7, 21);

  function draw_background(start_hour, end_hour) {
    var hours = end_hour - start_hour;
    context.fillStyle = "#000000"
    context.fillText("Monday", 0, 0);
    context.fillText("Tuesday", block_width, 0);
    context.fillText("Wednesday", 2*block_width, 0);
    context.fillText("Thursday", 3*block_width, 0);
    context.fillText("Friday", 4*block_width, 0);
    for (var j = 0; j < hours; j++) {
      var display_hour = start_hour+j;
      context.fillText(display_hour, 0, j*block_height, left_offset);
    }
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < hours; j++) {
        var x = left_offset + i * block_width;
        var y = top_offset + j * block_height;
        context.fillStyle = background_colors[0];
        context.fillRect(x, y, block_width, block_height);
        context.fillStyle = background_colors[1];
        context.strokeRect(x, y, block_width, block_height);
      }
    }
  }
});
