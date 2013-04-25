(function() {
  Danbooru.PostModeMenu = {};

  Danbooru.PostModeMenu.initialize = function() {
    if ($("#c-posts").length || $("#c-favorites").length || $("#c-pools").length) {
      this.initialize_selector();
      this.initialize_preview_link();
      this.initialize_edit_form();
      this.initialize_tag_script_field();
      Danbooru.PostModeMenu.change();
    }
  }

  Danbooru.PostModeMenu.initialize_selector = function() {
    if (Danbooru.Cookie.get("mode") === "") {
      Danbooru.Cookie.put("mode", "view");
      $("#mode-box select").val("view");
    } else {
      $("#mode-box select").val(Danbooru.Cookie.get("mode"));
    }

    $("#mode-box select").change(Danbooru.PostModeMenu.change);
  }

  Danbooru.PostModeMenu.initialize_preview_link = function() {
    $(".post-preview a").click(Danbooru.PostModeMenu.click);
  }

  Danbooru.PostModeMenu.initialize_edit_form = function() {
    $("#quick-edit-div").hide();
    $("#quick-edit-form input[value=Cancel]").click(function(e) {
      $("#quick-edit-div").slideUp("fast");
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
        success: function(data) {
          Danbooru.Post.update_data(data);
          $("#post_" + data.id).effect("shake", {distance: 5, times: 1}, 100);
          Danbooru.notice("Post #" + data.id + " updated");
        }
      });

      e.preventDefault();
    });
  }

  Danbooru.PostModeMenu.initialize_tag_script_field = function() {
    $("#tag-script-field").blur(function(e) {
      var script = $(this).val();

      if (script) {
        Danbooru.Cookie.put("tag-script", script);
      } else {
        $("#mode-box select").val("view");
        Danbooru.PostModeMenu.change(e);
      }
    });
  }

  Danbooru.PostModeMenu.change = function(e) {
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
      var script = Danbooru.Cookie.get("tag-script");

      $("#tag-script-field").val(script).show().focus().selectEnd();
    } else {
      $("#tag-script-field").hide();
    }
  }

  Danbooru.PostModeMenu.open_edit = function(post_id) {
    var $post = $("#post_" + post_id);
    $("#quick-edit-div").slideDown("fast");
    $("#quick-edit-form").attr("action", "/posts/" + post_id + ".json");
    $("#post_tag_string").val($post.data("tags") + " ").focus().selectEnd().height($("#post_tag_string")[0].scrollHeight);
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
    } else if (s === 'rating-q') {
      Danbooru.Post.update(post_id, {"post[rating]": "q"});
    } else if (s === 'rating-s') {
      Danbooru.Post.update(post_id, {"post[rating]": "s"});
    } else if (s === 'rating-e') {
      Danbooru.Post.update(post_id, {"post[rating]": "e"});
    } else if (s === 'lock-rating') {
      Danbooru.Post.update(post_id, {"post[is_rating_locked]": "1"});
    } else if (s === 'lock-note') {
      Danbooru.Post.update(post_id, {"post[is_note_locked]": "1"});
    } else if (s === 'approve') {
      Danbooru.Post.approve(post_id);
    } else if (s === "tag-script") {
      var tag_script = Danbooru.Cookie.get("tag-script");
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
