(function() {
  Danbooru.ArtistCommentary = {};

  Danbooru.ArtistCommentary.initialize_all = function() {
    if ($("#c-posts").length && $("#a-show").length) {
      if ($("#original-artist-commentary").length && $("#translated-artist-commentary").length) {
        this.initialize_commentary_display_tabs();
      }

      this.initialize_edit_commentary_dialog();
    }
  }

  Danbooru.ArtistCommentary.initialize_commentary_display_tabs = function() {
    $("#commentary-sections li a").click(function(e) {
      if (e.target.hash === "#original") {
        $("#original-artist-commentary").show();
        $("#translated-artist-commentary").hide();
      } else if (e.target.hash === "#translated") {
        $("#original-artist-commentary").hide();
        $("#translated-artist-commentary").show();
      }

      $("#commentary-sections li").removeClass("active");
      $(e.target).parent("li").addClass("active");
      e.preventDefault();
    });

    $("#commentary-sections li:last-child").addClass("active");
    $("#original-artist-commentary").hide();
  }

  Danbooru.ArtistCommentary.initialize_edit_commentary_dialog = function() {
    $("#add-commentary-dialog").dialog({
      autoOpen: false,
      width: 500,
      modal: true,
      buttons: {
        "Submit": function() {
          $("#add-commentary-dialog form").submit();
          $(this).dialog("close");
        },
        "Cancel": function() {
          $(this).dialog("close");
        }
      }
    });

    $('#add-commentary-dialog form').submit(function() {
      $('#add-commentary-dialog').dialog('close');
    });

    $("#add-commentary").click(function(e) {
      e.preventDefault();
      $("#add-commentary-dialog").dialog("open");
    });
  }
})();

$(function() {
  Danbooru.ArtistCommentary.initialize_all();
});
