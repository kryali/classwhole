function Tooltip(url, data) {
  this.url = url;
  this.data = data;
}

Tooltip.prototype.putAbove = function(element, margin, callback) {
  var that = this;
  $.ajax({
    type: 'POST',
    data: { "modal": this.url, "locals": this.data },
    url:  "/modal",
    success: function(data, textStatus, jqXHR) {
      var box_element = $(data);
      $("body").prepend(box_element);
      Utils.putAbove(box_element, element, margin);
      element.mouseenter(function() { that.cancel(); });
      element.mouseleave(function() { that.close(); });
      that.box_element = box_element;
      if (callback) callback();
    }
  });
}

Tooltip.prototype.close = function() {
  var box = this.box_element;
  this.closing_timeout = setTimeout(function() {
    box.remove();
  }, 250);
}

Tooltip.prototype.cancel = function() {
  if(typeof this.closing_timeout != "undefined") {
    clearTimeout( this.closing_timeout );
  }
}
