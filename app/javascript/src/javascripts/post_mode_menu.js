import CurrentUser from './current_user'
import Post from './posts.js.erb'
import Utility from './utility'

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

PostModeMenu.show_notice = function(i) {
  Utility.notice("Switched to tag script #" + i + ". To switch tag scripts, use the number keys.");
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
      PostModeMenu.show_notice(new_tag_script_id);
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
  $(document).on("click.danbooru", ".post-preview a", PostModeMenu.click);
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
  if (CurrentUser.data("enable-auto-complete")) {
    $("#post_tag_string").data("uiAutocomplete").close();
  }
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
  var $body = $(document.body);
  $body.removeClass((i, classNames) => classNames.split(/ /).filter(name => /^mode-/.test(name)).join(" "));
  $body.addClass("mode-" + s);
  localStorage.setItem("mode", s, 1);

  if (s === "tag-script") {
    var current_script_id = localStorage.getItem("current_tag_script_id");
    if (!current_script_id) {
      current_script_id = "1";
      localStorage.setItem("current_tag_script_id", current_script_id);
    }
    var script = localStorage.getItem("tag-script-" + current_script_id);

    $("#tag-script-field").val(script).show();
    PostModeMenu.show_notice(current_script_id);
  } else {
    $("#tag-script-field").hide();
  }
}

PostModeMenu.open_edit = function(post_id) {
  var $post = $("#post_" + post_id);
  $("#quick-edit-div").slideDown("fast");
  $("#quick-edit-form").attr("data-post-id", post_id);
  $("#post_tag_string").val($post.data("tags") + " ").focus().selectEnd();

  /* Set height of tag edit box to fit content. */
  $("#post_tag_string").height(80); // min height: 80px.
  var padding = $("#post_tag_string").innerHeight() - $("#post_tag_string").height();
  var height = $("#post_tag_string").prop("scrollHeight") - padding;
  $("#post_tag_string").height(height);
}

PostModeMenu.click = function(e) {
  var s = $("#mode-box select").val();
  var post_id = $(e.target).closest("article").data("id");

  if (s === "add-fav") {
    Post.tag(post_id, "fav:me");
  } else if (s === "remove-fav") {
    Post.tag(post_id, "-fav:me");
  } else if (s === "edit") {
    PostModeMenu.open_edit(post_id);
  } else if (s === 'vote-down') {
    Post.tag(post_id, "downvote:me");
  } else if (s === 'vote-up') {
    Post.tag(post_id, "upvote:me");
  } else if (s === "tag-script") {
    var current_script_id = localStorage.getItem("current_tag_script_id");
    var tag_script = localStorage.getItem("tag-script-" + current_script_id);
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
