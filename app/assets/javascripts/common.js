$(function() {
  // Table striping
  $(".striped tbody tr:even").addClass("even");
  $(".striped tbody tr:odd").addClass("odd");

  // More link
  if ($("#site-map-link").length > 0) {
    $("#site-map-link").click(function(e) {
      $("#more-links").toggle();
      e.preventDefault();
      e.stopPropagation();
    });

    $("#more-links").position({
      of: $("#site-map-link"),
      my: "left top",
      at: "left top"
    }).hide();

    $(document).click(function(e) {
      $("#more-links").hide();
    });
  }
  
  // Account notices
  $("#hide-sign-up-notice").click(function(e) {
    $("#sign-up-notice").hide();
    Danbooru.Cookie.put("hide_sign_up_notice", "1", 7);
    e.preventDefault();
  });
  
  $("#hide-upgrade-account-notice").click(function(e) {
    $("#upgrade-account-notice").hide();
    Danbooru.Cookie.put('hide_upgrade_account_notice', '1', 7);
    e.preventDefault();
  });
  
  // Ajax links
  $("a[data-remote=true]").click(function(e) {
    Danbooru.ajax_start(e.target);
  })
  
  $("a[data-remote=true]").ajaxComplete(function(e) {
    Danbooru.ajax_stop(e.target);
  })

  // TOS link
  if (!location.href.match(/terms_of_service/) && Danbooru.Cookie.get("tos") !== "1") {
    var domain = location.href.match(/^(http:\/\/[^\/]+)/)[0];
    location.href = domain + "/static/terms_of_service?url=" + location.href;
  }
  
  $("#tos-agree-link").click(function() {
    Danbooru.Cookie.put("tos", "1");
  })
});

var Danbooru = {};
