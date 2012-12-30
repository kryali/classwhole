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
      //console.log("parentHeight: " + parentHeight);
      //console.log("currentHeight: " + elementHeight);
      //console.log("verticalOffset: " + verticalOffset);
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
      var parent = $(node).parent();
      var parentVal = width ? parent.width() : parent.height();
      var totalChildrenVal = 0;
      $(node).siblings().each(function() {
        totalChildrenVal += width ? $(this).width() : $(this).height();
      });
      var leftOverVal = parentVal - totalChildrenVal;
      if (width) {
        $(node).css("width", leftOverVal); 
      } else {
        $(node).css("height", leftOverVal); 
      }
    }
  },

  layout: function() {
    Utils.allCenterVertical();
    Utils.allFill();
  },
}
