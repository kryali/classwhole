function login_to_rails() {
  FB.api('/me', function(user) {
    console.log(user);
    console.log("posting...");
    post_to_url('/user/login', user);
    console.log("posted");
  });
}

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

FB.init({
  appId  : '155445894543736',
  status : true, // check login status
  cookie : true, // enable cookies to allow the server to access the session
  xfbml  : true, // parse XFBML
  oauth  : true // enable OAuth 2.0
});

FB.Event.subscribe('auth.login', function(response) {
  console.log(response);
  post_to_url('user/register', response["authResponse"]);
});

FB.getLoginStatus(function(response) {
  if( response.status == "connected" ){
    //$("#fb-login").css("display","none");
    login_to_rails();
  }
});
