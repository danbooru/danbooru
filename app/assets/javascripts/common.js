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

  $("#hide-dmail-notice").click(function(e) {
    var $dmail_notice = $("#dmail-notice");
    $dmail_notice.hide();
    var dmail_id = $dmail_notice.data("id");
    Danbooru.Cookie.put("hide_dmail_notice", dmail_id);
    e.preventDefault();
  });

  $("#close-notice-link").click(function(e) {
    $('#notice').fadeOut("fast");
    e.preventDefault();
  });
});

var Danbooru = {};

var submitInvisibleRecaptchaForm = function () {
  document.getElementById("signup-form").submit();
};
