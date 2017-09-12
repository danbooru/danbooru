(function() {
  Danbooru.PostModeMenu = {};

  Danbooru.PostModeMenu.initialize = function() {
    if ($("#c-posts").length || $("#c-favorites").length || $("#c-pools").length) {
      this.initialize_selector();
      this.initialize_preview_link();
      this.initialize_edit_form();
      this.initialize_tag_script_field();
      this.initialize_shortcuts();
      Danbooru.PostModeMenu.change();
    }
  }

  Danbooru.PostModeMenu.initialize_shortcuts = function() {
    Danbooru.keydown("1 2 3 4 5 6 7 8 9 0", "change_tag_script", Danbooru.PostModeMenu.change_tag_script);
  }

  Danbooru.PostModeMenu.show_notice = function(i) {
    Danbooru.notice("Switched to tag script #" + i + ". To switch tag scripts, use the number keys.");    
  }
  
  Danbooru.PostModeMenu.change_tag_script = function(e) {
    if ($("#mode-box select").val() === "tag-script") {
      var old_tag_script_id = Danbooru.Cookie.get("current_tag_script_id") || "1";
      var old_tag_script = $("#tag-script-field").val();
      
      var new_tag_script_id = String.fromCharCode(e.which);
      var new_tag_script = Danbooru.Cookie.get("tag-script-" + new_tag_script_id);
    
      $("#tag-script-field").val(new_tag_script);
      Danbooru.Cookie.put("current_tag_script_id", new_tag_script_id);
      if (old_tag_script_id != new_tag_script_id) {
        Danbooru.PostModeMenu.show_notice(new_tag_script_id);
      }

      e.preventDefault();
    }
  }

  Danbooru.PostModeMenu.initialize_selector = function() {
    if (Danbooru.Cookie.get("mode") === "") {
      Danbooru.Cookie.put("mode", "view");
      $("#mode-box select").val("view");
    } else {
      $("#mode-box select").val(Danbooru.Cookie.get("mode"));
    }

    $("#mode-box select").change(function(e) {
      Danbooru.PostModeMenu.change();
      $("#tag-script-field:visible").focus().select();
    });
  }

  Danbooru.PostModeMenu.initialize_preview_link = function() {
    $(".post-preview a").click(Danbooru.PostModeMenu.click);
  }

  Danbooru.PostModeMenu.initialize_edit_form = function() {
    $("#quick-edit-div").hide();
    $("#quick-edit-form input[value=Cancel]").click(function(e) {
      Danbooru.PostModeMenu.close_edit_form();
      e.preventDefault();
    });

    $("#quick-edit-form").submit(function(e) {
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
          Danbooru.Post.update_data(data);
          $("#post_" + data.id).effect("shake", {distance: 5, times: 1}, 100);
          Danbooru.notice("Post #" + data.id + " updated");
          Danbooru.PostModeMenu.close_edit_form();
        }
      });

      e.preventDefault();
    });
  }

  Danbooru.PostModeMenu.close_edit_form = function() {
    $("#quick-edit-div").slideUp("fast");
    if (Danbooru.meta("enable-auto-complete") === "true") {
      $("#post_tag_string").data("uiAutocomplete").close();
    }
  }

  Danbooru.PostModeMenu.initialize_tag_script_field = function() {
    $("#tag-script-field").blur(function(e) {
      var script = $(this).val();

      if (script) {
        var current_script_id = Danbooru.Cookie.get("current_tag_script_id");
        Danbooru.Cookie.put("tag-script-" + current_script_id, script);
      } else {
        $("#mode-box select").val("view");
        Danbooru.PostModeMenu.change();
      }
    });
  }

  Danbooru.PostModeMenu.change = function() {
    $("#quick-edit-div").slideUp("fast");
    var s = $("#mode-box select").val();
    if (s === undefined) {
      return;
    }
    var $body = $(document.body);
    $body.removeClass();
    $body.addClass("mode-" + s);
    Danbooru.Cookie.put("mode", s, 1);

    if (s === "tag-script") {
      var current_script_id = Danbooru.Cookie.get("current_tag_script_id");
      if (!current_script_id) {
        current_script_id = "1";
        Danbooru.Cookie.put("current_tag_script_id", current_script_id);
      }
      var script = Danbooru.Cookie.get("tag-script-" + current_script_id);

      $("#tag-script-field").val(script).show();
      Danbooru.PostModeMenu.show_notice(current_script_id);
    } else {
      $("#tag-script-field").hide();
    }
  }

  Danbooru.PostModeMenu.open_edit = function(post_id) {
    var $post = $("#post_" + post_id);
    $("#quick-edit-div").slideDown("fast");
    $("#quick-edit-form").attr("action", "/posts/" + post_id + ".json");
    $("#post_tag_string").val($post.data("tags") + " ").focus().selectEnd();

    /* Set height of tag edit box to fit content. */
    $("#post_tag_string").height(80);  // min height: 80px.
    var padding = $("#post_tag_string").innerHeight() - $("#post_tag_string").height();
    var height = $("#post_tag_string").prop("scrollHeight") - padding;
    $("#post_tag_string").height(height);
  }

  Danbooru.PostModeMenu.click = function(e) {
    var s = $("#mode-box select").val();
    var post_id = $(e.target).closest("article").data("id");

    if (s === "add-fav") {
      Danbooru.Favorite.create(post_id);
    } else if (s === "remove-fav") {
      Danbooru.Favorite.destroy(post_id);
    } else if (s === "edit") {
      Danbooru.PostModeMenu.open_edit(post_id);
    } else if (s === 'vote-down') {
      Danbooru.Post.vote("down", post_id);
    } else if (s === 'vote-up') {
      Danbooru.Post.vote("up", post_id);
    } else if (s === 'lock-rating') {
      Danbooru.Post.update(post_id, {"post[is_rating_locked]": "1"});
    } else if (s === 'lock-note') {
      Danbooru.Post.update(post_id, {"post[is_note_locked]": "1"});
    } else if (s === 'approve') {
      Danbooru.Post.approve(post_id);
    } else if (s === 'ban') {
      Danbooru.Post.ban(post_id);
    } else if (s === "tag-script") {
      var current_script_id = Danbooru.Cookie.get("current_tag_script_id");
      var tag_script = Danbooru.Cookie.get("tag-script-" + current_script_id);
      Danbooru.TagScript.run(post_id, tag_script);
    } else {
      return;
    }

    e.preventDefault();
  }
})();

$(function() {
  Danbooru.PostModeMenu.initialize();
});
