$(function(){
  $(document).ajaxSend( function(e, xhr, options) {
    if ( options.type == 'post' ) {
      options.data = (options.data ? options.data + "&" : "") + "authenticity_token=" + encodeURIComponent( AUTH_TOKEN );
    }
    xhr.setRequestHeader("X-CSRF-Token", AUTH_TOKEN);
  });
  Utils.layout();

  MutationObserver = window.MutationObserver || window.WebKitMutationObserver;

  var observer = new MutationObserver(function(mutations, observer) {
    Utils.layout();
  });

  // define what element should be observed by the observer
  // and what types of mutations trigger the callback
  var options =  {
    subtree: true,
    attributes: false,
    childList: true,
  };
  observer.observe($("ul.courses")[0], options);

});
