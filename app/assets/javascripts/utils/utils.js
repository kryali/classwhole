Utils = {

  getRandom: function( min, max ) {
      var range = (max - min);
      var rand = Math.random();
      var res = (rand * range) + min;
      return res;
  },

  allCenterVertical: function() {
    $(".vertical-center").each(function() {
      $(this).parent().css("position", "relative");
      var parentHeight = $(this).parent().height();
      var elementHeight = $(this).height();
      var verticalOffset = Math.ceil((parentHeight - elementHeight)/2);
      $(this).css("position", "absolute");
      $(this).css("top", verticalOffset);
    });
  },

  fill: function(node, width) {
    var freeSpace = Utils.getFreeSpace(node);
    if (width) {
      $(node).css("width", freeSpace.width); 
    } else {
      $(node).css("height", freeSpace.height); 
    }
  },

  fillWidth: function(block) {
    Utils.fill(block, true);
  },

  fillHeight: function(block) {
    Utils.fill(block, false);
  },

  truncate: function(node, extra) {
    var node = $(node);
    var text = node.text();
    if (text.match("{{.*}}") != null) return; // This is a template, fuck off.

    var freeSpace = Utils.getFreeSpace(node);
    freeSpace.width -= extra; // fragile lol
    if (node.width() <= freeSpace.width) return;

    var textLength = text.length;
    while (node.width() > freeSpace.width) {
      node.text(text.substring(0, textLength) + "...");
      textLength--;
    }
  },

  putAbove: function(element, target, margin) {
    var offset = target.offset();
    var height = element.outerHeight();
    var width = element.outerWidth();

    var otop = offset.top - (height + margin);
    var left = offset.left - width/2 + target.width()/2;

    element.css("top", otop)
    element.css("left", left);
    element.css("display", "absolute");
  },

  // fragile : doesn't consider floated elements or padding or margin or anything like that
  getFreeSpace: function(node) {
    var parent = $(node).parent();
    var parentWidth = parent.width();
    var parentHeight = parent.height();
    var siblingWidth = 0;
    var siblingHeight = 0;
    $(node).siblings().each(function() {
      siblingWidth += $(this).width();
      siblingHeight += $(this).height();
    });
    return { 'width': parentWidth - siblingWidth, 'height': parentHeight - siblingHeight }
  },

  deepCopy: function(obj) {
    return jQuery.extend(true, {}, obj);
  },

  copyArray: function(array) {
    var copy = [];
    for (var i in array) {
      copy.push(array[i]);
    }
    return copy;
  }
}
