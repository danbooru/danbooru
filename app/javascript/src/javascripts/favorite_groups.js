import Rails from "@rails/ujs";

let FavoriteGroup = {};

FavoriteGroup.initialize_all = function() {
  if ($("#c-posts").length && $("#a-show").length) {
    this.initialize_add_to_favgroup_dialog();
  }
}

FavoriteGroup.initialize_add_to_favgroup_dialog = function() {
  $("#add-to-favgroup-dialog").dialog({
    autoOpen: false,
    width: 700,
    buttons: {
      "Cancel": function() {
        $(this).dialog("close");
      }
    }
  });

  $("#open-favgroup-dialog-link").on("click.danbooru", FavoriteGroup.open_favgroup_dialog);
}

FavoriteGroup.open_favgroup_dialog = function(e) {
  if ($(".add-to-favgroup").length === 1) {
    // If the user only has one favorite group we don't need to ask which group to add the post to.
    let favgroup = $(".add-to-favgroup").get(0);
    Rails.fire(favgroup, "click");
  } else {
    $("#add-to-favgroup-dialog").dialog("open");
  }
  e.preventDefault();
}

$(function() {
  FavoriteGroup.initialize_all();
});

export default FavoriteGroup
