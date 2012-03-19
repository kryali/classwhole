$(document).keyup(function(e) {
  if (e.keyCode == 27) { hideModal(); }   // esc
});

function showModal(modal, locals) {
  $.ajax({
    type: 'POST',
    data: { "modal": modal, "locals": locals },
    url:  "/modal",
    success: function(data, textStatus, jqXHR) {
      $(".modalContainer").append(data);
      init_fb();
      var modal_page = document.getElementById('modalPage')
      modal_page.style.display = "block";
      modal_page.style.top = document.body.scrollTop;
    }
  });
}

function hideModal() {
  document.getElementById('modalPage').style.display = "none";
  $(".modalContainer").empty();
}

