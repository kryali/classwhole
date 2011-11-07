/*
 * fb_button_init.js
 * File Summary: initializes the facebook sdk and contains login logic via facebook 
 */
 

$(document).ready(function() { 

  /* Constants */
  var LOGIN_PATH = "/user/login";


  /*
   * This creates a hidden form and posts this data to rails
   *  A BETTER way would be to actually have a hidden form on the login page,
   *  That way - we wouldn't have to pass the AUTH_TOKEN from rails into the javascript
   */
  function post_to_url(path, params, method) {
      method = method || "post"; // Set method to post by default, if not specified.
      $.ajax({
        type: 'POST',
        url: path,
        data: params,
        success: function( data, textStatus, xqHR){
          //pop_alert( textStatus, data["message"] );
          //console.log(data["user"]["name"]);
          $("ul.secondary-nav li").empty().append( $("<a/>").text( data["user"]["name"] ) );
          $("#save-modal").modal("hide");
          $(document).trigger("logged-in");
        }
      });
  }


  /* 
   * FB.init starts the facebook sdk, enabling calls against the facebook api
   * also, the facebook "sdk" sucks.
   */
  FB.init({
    appId  : '227782147288218',
    status : true, // check login status
    cookie : true, // enable cookies to allow the server to access the session
    xfbml  : true, // parse XFBML
    oauth  : true // enable OAuth 2.0
  });

  FB.getLoginStatus(function(response) {
    if(response.authResponse){
      //console.log( "User is logged into facebook already!" );
      /* User is logged in to facebook, let him in */
      //console.log( response.authResponse );
      //post_to_url(LOGIN_PATH, response["authResponse"]);
    }
  });

  /* When a user clicks a button, */
  $('.fb-button').click( function(event) {

    //console.log("Button clicked!");
    /* FB.getLoginStatus allows you to determine if a user is 
     * logged into facebook.*/
    FB.getLoginStatus(function(response) {
      if(response.authResponse){
        /* User is logged in to facebook, let him in */
        post_to_url(LOGIN_PATH, response["authResponse"]);
      }
    });

    /* FB.Event.subscribe('auth.login') gets fired when the user logs in
     * Register the user by silently posting a form to rails */
    FB.Event.subscribe('auth.login', function(response) {
      post_to_url(LOGIN_PATH, response["authResponse"]);
    });

  });


});
