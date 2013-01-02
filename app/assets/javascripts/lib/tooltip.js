function Tooltip( url, data) {
  this.url = url;
  this.data = data;
}

Tooltip.prototype.putAbove = function( element, callback ) {
  var that = this;
  $.ajax({
    type: 'POST',
    data: { "modal": this.url, "locals": this.data },
    url:  "/modal",
    success: function(data, textStatus, jqXHR) {
      var PADDING = 5;
      var offset = element.offset();
      var box_element = $(data);
      $("body").prepend( box_element );

      var height = box_element.height();
      var width = box_element.width();

      var otop = offset.top - (height + PADDING);
      var left = offset.left - width/2 + element.width()/2;
      box_element.css("top", otop).css("left", left);
      box_element.mouseenter( function() { that.cancel(); });
      box_element.mouseleave( function() { that.close(); });
      that.box_element = box_element;
      callback();
    }
  });
}

Tooltip.prototype.close = function() {
  var box = this.box_element;
  this.closing_timeout = setTimeout(function() {
    box.remove();
  }, 550);
}

Tooltip.prototype.cancel = function() {
  if( typeof this.closing_timeout != "undefined" ) {
    clearTimeout( this.closing_timeout );
  }
}
