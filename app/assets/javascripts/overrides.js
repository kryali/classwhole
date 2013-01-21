$(function(){
    var overrideClasses = ["hover"];

    function addClass(element, arguments) {
      for( var i = 0; i < overrideClasses.length; i++) {
        if (arguments[0] == overrideClasses[i]) {
          $(document).trigger('addClass', overrideClasses[i], element);
        }
      }
    }

    function removeClass(element, arguments) {
      for( var i = 0; i < overrideClasses.length; i++) {
        if (arguments[0] == overrideClasses[i]) {
          $(document).trigger('removeClass', overrideClasses[i], element);
        }
      }
    }

    var originalAddClassMethod = jQuery.fn.addClass;
    jQuery.fn.addClass = function(){
        var result = originalAddClassMethod.apply(this, arguments);
        addClass(this, arguments);
        return result;
    }

    var originalRemoveClassMethod = jQuery.fn.removeClass;
    jQuery.fn.removeClass = function(){
        var result = originalRemoveClassMethod.apply(this, arguments);
        removeClass(this, arguments);
        return result;
    }

    $(document).bind("addClass", function(event, className) {
      if (className == "hover") {
        $(".ui-draggable-dragging").addClass("hovering");
      }
    });

    $(document).bind("removeClass", function(event, className) {
      if (className == "hover") {
        $(".ui-draggable-dragging").removeClass("hovering");
      }
    });
});
