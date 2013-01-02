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

  allFill: function() {
    $(".fill-width").each(function() {
      fill(this, true);
    });

    $(".fill-height").each(function() {
      fill(this, false);
    });

    function fill(node, width) {
      var freeSpace = Utils.getFreeSpace(node);
      if (width) {
        $(node).css("width", freeSpace.width); 
      } else {
        $(node).css("height", freeSpace.height); 
      }
    }
  },

  layout: function() {
    Utils.allCenterVertical();
    Utils.allFill();
    Utils.truncateAll();
  },

  // Private? damnit I don't understand javascript

  truncateAll: function() {
    $(".truncate").each(function() {
      var node = $(this);
      var text = node.text();
      if (text.match("{{.*}}") != null) return; // This is a template, fuck off.

      var freeSpace = Utils.getFreeSpace(this);
      freeSpace.width -= 30; // fragile lol
      if (node.width() <= freeSpace.width) return;

      var textLength = text.length;
      while (node.width() > freeSpace.width) {
        node.text(text.substring(0, textLength) + "...");
        textLength--;
      }
    });
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
}
