import Cookie from './cookie'

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

  let enable_antiproxying = $("body").data("config-environment") === "production";
  let hostname = $("body").data("config-hostname");
  let domain = $("body").data("config-domain");

  if (enable_antiproxying && !location.hostname.endsWith(domain)) {
    location.hostname = hostname;
  }
});

window.submitInvisibleRecaptchaForm = function () {
  document.getElementById("signup-form").submit();
}
