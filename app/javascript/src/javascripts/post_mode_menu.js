import Cookie from './cookie'
import CurrentUser from './current_user'
import Favorite from './favorites'
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
    var old_tag_script_id = Cookie.get("current_tag_script_id") || "1";

    var new_tag_script_id = String.fromCharCode(e.which);
    var new_tag_script = Cookie.get("tag-script-" + new_tag_script_id);

    $("#tag-script-field").val(new_tag_script);
    Cookie.put("current_tag_script_id", new_tag_script_id);
    if (old_tag_script_id !== new_tag_script_id) {
      PostModeMenu.show_notice(new_tag_script_id);
    }

    e.preventDefault();
  }
}

PostModeMenu.initialize_selector = function() {
  if (Cookie.get("mode") === "") {
    Cookie.put("mode", "view");
    $("#mode-box select").val("view");
  } else {
    $("#mode-box select").val(Cookie.get("mode"));
  }

  $("#mode-box select").on("change.danbooru", function(e) {
    PostModeMenu.change();
    $("#tag-script-field:visible").focus().select();
  });
}

PostModeMenu.initialize_preview_link = function() {
  $(".post-preview a").on("click.danbooru", PostModeMenu.click);
}

PostModeMenu.initialize_edit_form = function() {
  $("#quick-edit-div").hide();
  $("#quick-edit-form input[value=Cancel]").on("click.danbooru", function(e) {
    PostModeMenu.close_edit_form();
    e.preventDefault();
  });

  $("#quick-edit-form").on("submit.danbooru", function(e) {
    $.ajax({
      type: "put",
      url: $("#quick-edit-form").attr("action"),
      data: {
        post: {
          tag_string: $("#post_tag_string").val()
        }
      },
      complete: function() {
        $.rails.enableFormElements($("#quick-edit-form"));
      },
      success: function(data) {
        Post.update_data(data);
        Utility.notice("Post #" + data.id + " updated");
        PostModeMenu.close_edit_form();
      }
    });

    e.preventDefault();
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
      var current_script_id = Cookie.get("current_tag_script_id");
      Cookie.put("tag-script-" + current_script_id, script);
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
  Cookie.put("mode", s, 1);

  if (s === "tag-script") {
    var current_script_id = Cookie.get("current_tag_script_id");
    if (!current_script_id) {
      current_script_id = "1";
      Cookie.put("current_tag_script_id", current_script_id);
    }
    var script = Cookie.get("tag-script-" + current_script_id);

    $("#tag-script-field").val(script).show();
    PostModeMenu.show_notice(current_script_id);
  } else {
    $("#tag-script-field").hide();
  }
}

PostModeMenu.open_edit = function(post_id) {
  var $post = $("#post_" + post_id);
  $("#quick-edit-div").slideDown("fast");
  $("#quick-edit-form").attr("action", "/posts/" + post_id + ".json");
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
    Favorite.create(post_id);
  } else if (s === "remove-fav") {
    Favorite.destroy(post_id);
  } else if (s === "edit") {
    PostModeMenu.open_edit(post_id);
  } else if (s === 'vote-down') {
    Post.vote("down", post_id);
  } else if (s === 'vote-up') {
    Post.vote("up", post_id);
  } else if (s === 'lock-rating') {
    Post.update(post_id, {"post[is_rating_locked]": "1"});
  } else if (s === 'lock-note') {
    Post.update(post_id, {"post[is_note_locked]": "1"});
  } else if (s === 'approve') {
    Post.approve(post_id);
  } else if (s === 'ban') {
    Post.ban(post_id);
  } else if (s === "tag-script") {
    var current_script_id = Cookie.get("current_tag_script_id");
    var tag_script = Cookie.get("tag-script-" + current_script_id);
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
