import Cookie from './cookie'

$(function() {
  $("#hide-upgrade-account-notice").on("click.danbooru", function(e) {
    $("#upgrade-account-notice").hide();
    Cookie.put('hide_upgrade_account_notice', '1', 7 * 24 * 60 * 60);
    e.preventDefault();
  });

  $("#hide-promotion-notice").on("click.danbooru", function(e) {
    $("#promotion-notice").hide();
    Cookie.put("hide_winter_sale_notice", "1", 1 * 60 * 60);
    Cookie.put("hide_upgrade_account_notice", "1", 7 * 24 * 60 * 60);
    e.preventDefault();
  });

  $("#hide-dmail-notice").on("click.danbooru", function(e) {
    var $dmail_notice = $("#dmail-notice");
    $dmail_notice.hide();
    var dmail_id = $dmail_notice.data("id");
    Cookie.put("hide_dmail_notice", dmail_id);
    e.preventDefault();
  });

  $("#hide-verify-account-notice").on("click.danbooru", function(e) {
    $("#verify-account-notice").hide();
    Cookie.put('hide_verify_account_notice', '1', 3 * 24 * 60 * 60);
    e.preventDefault();
  });

  $.widget("ui.dialog", $.ui.dialog, {
    options: {
      classes: { "ui-dialog-content": "thin-scrollbar", }
    }
  });

  $("meta[name=reportbooru-beacon]").each((i, meta) => navigator.sendBeacon(meta.content, new URLSearchParams(JSON.parse(meta.dataset.params))));

  $("form[data-autosubmit]").each((i, form) => form.submit());

  if (location.hostname.endsWith("danbooru.me")) {
    location.hostname = "danbooru.donmai.us";
  }
});
