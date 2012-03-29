Utils = {

  getRandom: function( min, max ) {
      var range = (max - min);
      var rand = Math.random();
      var res = (rand * range) + min;
      return res;
  },

  getCenter: function( element ) {
    var mainHeight = element.outerHeight();
    var mainWidth = element.outerWidth();
    var windowHeight = window.innerHeight;
    var offsetHeight = (windowHeight-mainHeight)/2;
    offsetHeight = ( offsetHeight > 0 )? offsetHeight + "px" : 50 + "px";
    var windowWidth = window.innerWidth;
    var offsetWidth = (windowWidth-mainWidth)/2 + "px";
    return { left: offsetWidth, top: offsetHeight };
  },

  centerElement: function( element ) {
    var center = this.getCenter(element);
    element.css('top', center.top);
    element.css('left', center.left);
  },

  centerAll: function() {
    var elements = $(".vertical-center");
    elements.each( function() {
      Utils.centerElement( $(this) );
    });
  },
}
