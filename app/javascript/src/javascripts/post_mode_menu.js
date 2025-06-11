import Post from './posts.js'
import Utility from './utility'
import Notice from './notice'

let PostModeMenu = {};

PostModeMenu.initialize = function() {
  if ($("#c-posts").length || $("#c-favorites").length || $("#c-pools").length) {
    this.initialize_selector();
    this.initialize_preview_link();
    this.initialize_edit_form();
    this.initialize_tag_script_field();
    this.initialize_shortcuts();
    PostModeMenu.change();
  }
}

PostModeMenu.initialize_shortcuts = function() {
  Utility.keydown("1 2 3 4 5 6 7 8 9 0", "change_tag_script", PostModeMenu.change_tag_script);
}

PostModeMenu.show_notice = function(mode, tag_script_index = 0) {
  if (mode === "add-fav") {
    Notice.info("Switched to favorite mode. Click a post to favorite it.");
  } else if (mode === "remove-fav") {
    Notice.info("Switched to unfavorite mode. Click a post to unfavorite it.");
  } else if (mode === "edit") {
    Notice.info("Switched to edit mode. Click a post to edit it.");
  } else if (mode === "tag-script") {
    Notice.info(`Switched to tag script #${tag_script_index}. To switch tag scripts, use the number keys.`);
  }
}

PostModeMenu.change_tag_script = function(e) {
  if ($("#mode-box select").val() === "tag-script") {
    var old_tag_script_id = localStorage.getItem("current_tag_script_id") || "1";

    var keycode = e.which >= 96 ? e.which - 48 : e.which;
    var new_tag_script_id = String.fromCharCode(keycode);
    var new_tag_script = localStorage.getItem("tag-script-" + new_tag_script_id);

    $("#tag-script-field").val(new_tag_script);
    localStorage.setItem("current_tag_script_id", new_tag_script_id);
    if (old_tag_script_id !== new_tag_script_id) {
      PostModeMenu.show_notice("tag-script", new_tag_script_id);
    }

    e.preventDefault();
  }
}

PostModeMenu.initialize_selector = function() {
  let mode = localStorage.getItem("mode");
  if (mode === null) {
    localStorage.setItem("mode", "view");
    $("#mode-box select").val("view");
  } else {
    $("#mode-box select").val(mode);
  }

  $("#mode-box select").on("change.danbooru", function(e) {
    PostModeMenu.change();
    $("#tag-script-field:visible").focus().select();
  });
}

PostModeMenu.initialize_preview_link = function() {
  $(document).on("click.danbooru", ".post-preview-container a", PostModeMenu.click);
}

PostModeMenu.initialize_edit_form = function() {
  $("#quick-edit-div").hide();

  $(document).on("click.danbooru", "#quick-edit-form button[name=cancel]", function(e) {
    PostModeMenu.close_edit_form();
    e.preventDefault();
  });

  $(document).on("click.danbooru", "#quick-edit-form input[type=submit]", async function(e) {
    e.preventDefault();
    let post_id = $("#quick-edit-form").attr("data-post-id");
    await Post.update(post_id, "quick-edit", { post: { tag_string: $("#post_tag_string").val() }});
  });
}

PostModeMenu.close_edit_form = function() {
  $("#quick-edit-div").slideUp("fast");
  $("#post_tag_string").data("uiAutocomplete").close();
}

PostModeMenu.initialize_tag_script_field = function() {
  $("#tag-script-field").blur(function(e) {
    var script = $(this).val();

    if (script) {
      var current_script_id = localStorage.getItem("current_tag_script_id");
      localStorage.setItem("tag-script-" + current_script_id, script);
    } else {
      $("#mode-box select").val("view");
      PostModeMenu.change();
    }
  });
}

PostModeMenu.change = function() {
  $("#quick-edit-div").slideUp("fast");
  var s = $("#mode-box select").val();
  if (s === undefined) {
    return;
  }

  $("body").attr("data-mode-menu-active", s !== "view");
  $("body").attr("data-mode-menu", s);
  localStorage.setItem("mode", s, 1);

  if (s === "tag-script") {
    var current_script_id = localStorage.getItem("current_tag_script_id");
    if (!current_script_id) {
      current_script_id = "1";
      localStorage.setItem("current_tag_script_id", current_script_id);
    }
    var script = localStorage.getItem("tag-script-" + current_script_id);

    $("#tag-script-field").val(script).show();
    PostModeMenu.show_notice(s, current_script_id);
  } else {
    $("#tag-script-field").hide();
    PostModeMenu.show_notice(s);
  }
}

PostModeMenu.open_edit = function(post_id) {
  var $post = $("#post_" + post_id);
  $("#quick-edit-div").slideDown("fast");
  $("#quick-edit-form").attr("data-post-id", post_id);
  $("#post_tag_string").val($post.data("tags") + " ").focus().selectEnd();
}

PostModeMenu.click = function(e) {
  if (e.ctrlKey || e.shiftKey || e.altKey || e.metaKey) {
    return;
  }

  var s = $("#mode-box select").val();
  var post_id = $(e.target).closest("article").data("id");

  if (s === "add-fav") {
    Post.tag(post_id, "fav:me");
  } else if (s === "remove-fav") {
    Post.tag(post_id, "-fav:me");
  } else if (s === "edit") {
    PostModeMenu.open_edit(post_id);
  } else if (s === "tag-script") {
    var current_script_id = localStorage.getItem("current_tag_script_id");
    var tag_script = localStorage.getItem("tag-script-" + current_script_id) ?? "";
    Post.tag(post_id, tag_script);
  } else {
    return;
  }

  e.preventDefault();
}

$(function() {
  PostModeMenu.initialize();
});

export default PostModeMenu
