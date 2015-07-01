(function() {
  Danbooru.FavoriteGroup = {};

  Danbooru.FavoriteGroup.initialize_all = function() {
    if ($("#c-posts").length && $("#a-show").length) {
      this.initialize_add_to_favgroup_dialog();
      $(document).bind("keydown", "1 2 3 4 5 6 7 8 9 0", Danbooru.FavoriteGroup.add_to_favgroup);
    }
  }

  Danbooru.FavoriteGroup.initialize_add_to_favgroup_dialog = function() {
    $("#add-to-favgroup-dialog").dialog({
      autoOpen: false,
      width: 500,
      buttons: {
        "Cancel": function() {
          $(this).dialog("close");
        }
      }
    });

    $(document).bind("keydown", "g", function(e) {
      if ($(".add-to-favgroup").length === 1) {
        // If the user only has one favorite group we don't need to ask which group to add the post to.
        $(".add-to-favgroup").click();
      } else if ($(".add-to-favgroup").length > 1) {
        $("#add-to-favgroup-dialog").dialog("open");
      }
      e.preventDefault();
    });
  }

  Danbooru.FavoriteGroup.add_to_favgroup = function(e) {
    var favgroup_index = String.fromCharCode(e.which);
    var link = $("#add-to-favgroup-" + favgroup_index + ":visible");
    if (link.length) {
      link.click();
    }
  }
})();

$(function() {
  Danbooru.FavoriteGroup.initialize_all();
});
