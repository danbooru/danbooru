import Cookie from './cookie'
import CurrentUser from './current_user'

$(function() {
  $("#hide-upgrade-account-notice").on("click.danbooru", function(e) {
    $("#upgrade-account-notice").hide();
    Cookie.put('hide_upgrade_account_notice', '1', 7);
    e.preventDefault();
  });

  $("#hide-dmail-notice").on("click.danbooru", function(e) {
    var $dmail_notice = $("#dmail-notice");
    $dmail_notice.hide();
    var dmail_id = $dmail_notice.data("id");
    Cookie.put("hide_dmail_notice", dmail_id);
    e.preventDefault();
  });

  $("#close-notice-link").on("click.danbooru", function(e) {
    $('#notice').fadeOut("fast");
    e.preventDefault();
  });

  $("#desktop-version-link a").on("click.danbooru", async function(e) {
    e.preventDefault();
    await CurrentUser.update({ disable_responsive_mode: true });
    location.reload();
  });
});

window.submitInvisibleRecaptchaForm = function () {
  document.getElementById("signup-form").submit();
}
