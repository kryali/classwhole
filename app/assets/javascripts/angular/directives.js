
function domReady(callback) {
  return {
    link: function($scope, iElement, iAttrs) {
      $(function() {
        // Sometimes Angular calls us before the page is completely laid out
        // Saving it for the next tick somehow fixes this. #witchcraft #fuckingwebdev
        setTimeout(function() {
          callback($scope, iElement, iAttrs);
        }, 0);
      });
    }
  }
}

