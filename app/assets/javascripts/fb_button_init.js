/*
 * fb_button_init.js
 * File Summary: initializes the facebook sdk and contains login logic via facebook 
 */

$(document).ready(function() { 

  /*
   * This creates a hidden form and posts this data to rails
   */
  function post_to_url(path, params, method) {
      method = method || "post"; // Set method to post by default, if not specified.

      // The rest of this code assumes you are not using a library.
      // It can be made less wordy if you use one.
      var form = document.createElement("form");
      form.setAttribute("method", method);
      form.setAttribute("action", path);
      form.setAttribute("authenticity_token", AUTH_TOKEN);

      for(var key in params) {
          var hiddenField = document.createElement("input");
          hiddenField.setAttribute("type", "hidden");
          hiddenField.setAttribute("name", key);
          hiddenField.setAttribute("value", params[key]);
          hiddenField.setAttribute("authenticity_token", AUTH_TOKEN);
          form.appendChild(hiddenField);
      }
      document.body.appendChild(form);    // Not entirely sure if this is necessary
      form.submit();
  }

  /* 
   * FB.init starts the facebook sdk, enabling calls against the facebook api
   * also, the facebook "sdk" sucks.
   */
  FB.init({
    appId  : '155445894543736',
    status : true, // check login status
    cookie : true, // enable cookies to allow the server to access the session
    xfbml  : true, // parse XFBML
    oauth  : true // enable OAuth 2.0
  });


  /* When a user clicks a button, */
  $('#fb-button').click( function(event) {

    /* FB.getLoginStatus allows you to determine if a user is 
     * logged in and connected to your app.*/
    FB.getLoginStatus(function(response) {
      if( response.authResponse ) {
        /* Log the user in with it's facebook graph data */
        FB.api('/me', function(user) {
          post_to_url('/user/login', user);
        });
      }
    });

    /* FB.Event.subscribe('auth.login') gets fired when the user logs in
     * Register the user by silently posting a form to rails */
    FB.Event.subscribe('auth.login', function(response) {
      post_to_url('user/register', response["authResponse"]);
    });
  });
});
