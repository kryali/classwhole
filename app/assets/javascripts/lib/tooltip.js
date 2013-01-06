function Tooltip(url, data) {
  this.url = url;
  this.data = data;
}

Tooltip.prototype.putAbove = function(element, margin, callback) {
  var show = true;
  element.mouseleave(function() {
    show = false;
  });

  
  $.ajax({
    type: 'POST',
    data: { "modal": this.url, "locals": this.data },
    url:  "/modal",
    success: function(data, textStatus, jqXHR) {
      if (!show) return;
      var box_element = $(data);
      $("body").prepend(box_element);
      Utils.putAbove(box_element, element, margin);
      element.mouseleave(function() { box_element.remove(); });
      if (callback) callback();
    }
  });
}
