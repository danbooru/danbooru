(function() {
  Danbooru.PostAppeal = {};

  Danbooru.PostAppeal.initialize_all = function() {
    if ($("#c-posts").length && $("#a-show").length) {
      this.initialize_appeal();
      this.hide_or_show_appeal_link();
    }
  }

  Danbooru.PostAppeal.hide_or_show_appeal_link = function() {
    if (Danbooru.meta("post-is-flagged") !== "true") {
      $("#appeal").hide();
    }
  }

  Danbooru.PostAppeal.initialize_appeal = function() {
    $("#appeal-dialog").dialog({
      autoOpen: false,
      width: 700,
      modal: true,
      buttons: {
        "Submit": function() {
          $("#appeal-dialog form").submit();
          $(this).dialog("close");
        },
        "Cancel": function() {
          $(this).dialog("close");
        }
      }
    });

    $("#appeal").click(function(e) {
      e.preventDefault();
      $("#appeal-dialog").dialog("open");
    });
  }
})();

$(document).ready(function() {
  Danbooru.PostAppeal.initialize_all();
});
