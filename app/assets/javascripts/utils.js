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

  allFillWidth: function() {
    $(".fill-width").each(function() {
      console.log(this);
      var parent = $(this).parent();
      var parentWidth = parent.width();
      var totalChildrenWidth = 0;
      parent.children().each(function() {
        totalChildrenWidth += $(this).width();
        console.log($(this));
      });
      totalChildrenWidth -= $(this).width();
      var leftOverWidth = parentWidth - totalChildrenWidth;
      console.log("parentWidth: " + parentWidth);
      console.log("totalChildrenWidth: " + totalChildrenWidth);
      console.log("leftOverWidth: " + leftOverWidth);
      $(this).css("width", leftOverWidth); 
    });
  }
}
