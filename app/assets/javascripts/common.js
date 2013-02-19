$(function() {
  // Table striping
  $(".striped tbody tr:even").addClass("even");
  $(".striped tbody tr:odd").addClass("odd");
  
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
