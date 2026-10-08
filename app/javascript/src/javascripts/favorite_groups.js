import Utility from "./utility";

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
  $("#add-to-favgroup-dialog .add-to-favgroup").on("click.danbooru", FavoriteGroup.add_post);
}

FavoriteGroup.add_post = function(e) {
  if (e.ctrlKey || e.metaKey || e.shiftKey) {
    return;
  }

  e.preventDefault();
  let favgroup_id = $(e.currentTarget).data("favgroup-id");
  $.ajax({ type: "PUT", url: `/favorite_groups/${favgroup_id}/add_post.js`, data: { post_id: Utility.meta("post-id") } }).done(script => $.globalEval(script));
}

FavoriteGroup.open_favgroup_dialog = function(e) {
  $("#add-to-favgroup-dialog").dialog("open");
  e.preventDefault();
}

$(function() {
  FavoriteGroup.initialize_all();
});

export default FavoriteGroup
