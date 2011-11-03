$(function(){
  $(document).ajaxSend( function(e, xhr, options) {
    if ( options.type == 'post' ) {
      options.data = (options.data ? options.data + "&" : "") + "authenticity_token=" + encodeURIComponent( AUTH_TOKEN );
    }
    xhr.setRequestHeader("X-CSRF-Token", AUTH_TOKEN);
  } );
});
