import Cookie from './cookie'
import Utility from './utility'

$(function() {
  // Account notices
  $("#hide-sign-up-notice").click(function(e) {
    $("#sign-up-notice").hide();
    Cookie.put("hide_sign_up_notice", "1", 7);
    e.preventDefault();
  });

  $("#hide-upgrade-account-notice").click(function(e) {
    $("#upgrade-account-notice").hide();
    Cookie.put('hide_upgrade_account_notice', '1', 7);
    e.preventDefault();
  });

  $("#hide-dmail-notice").click(function(e) {
    var $dmail_notice = $("#dmail-notice");
    $dmail_notice.hide();
    var dmail_id = $dmail_notice.data("id");
    Cookie.put("hide_dmail_notice", dmail_id);
    e.preventDefault();
  });

  $("#close-notice-link").click(function(e) {
    $('#notice').fadeOut("fast");
    e.preventDefault();
  });

  $("#desktop-version-link a").click(function(e) {
    e.preventDefault();
    $.ajax("/users/" + Utility.meta("current-user-id") + ".json", {
      method: "PUT",
      data: {
        "user[disable_responsive_mode]": "true"
      }
    }).then(function() {
      location.reload();
    });
  });
});

window.submitInvisibleRecaptchaForm = function () {
  document.getElementById("signup-form").submit();
}
