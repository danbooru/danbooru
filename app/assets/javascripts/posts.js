(function() {
  Danbooru.Post = {};

  Danbooru.Post.pending_update_count = 0;

  Danbooru.Post.initialize_all = function() {
    this.initialize_post_previews();

    if ($("#c-posts").length) {
      if (Danbooru.meta("enable-js-navigation") === "true") {
        this.initialize_shortcuts();
      }
    }

    if ($("#c-posts").length && $("#a-index").length) {
      this.initialize_excerpt();
    }

    if ($("#c-posts").length && $("#a-show").length) {
      this.initialize_links();
      this.initialize_post_relationship_previews();
      this.initialize_favlist();
      this.initialize_post_sections();
      this.initialize_post_image_resize_links();
      this.initialize_post_image_resize_to_window_link();
      this.initialize_similar();

      if (Danbooru.meta("always-resize-images") === "true") {
        $("#image-resize-to-window-link").click();
      }
    }

    if ($("#image").length) {
      this.initialize_edit_dialog();
    }
  }

  Danbooru.Post.initialize_edit_dialog = function(e) {
    $("#open-edit-dialog").button().show().click(function(e) {
      $(window).scrollTop($("#image").offset().top);
      Danbooru.Post.open_edit_dialog();
      e.preventDefault();
    });

    $("#toggle-related-tags-link").click(function(e) {
      var $related_tags = $("#related-tags");
      if ($related_tags.is(":visible")) {
        $related_tags.hide();
        $(e.target).html("&raquo;");
      } else {
        $related_tags.show();
        $("#related-tags-button").trigger("click");
        $("#find-artist-button").trigger("click");
        $(e.target).html("&laquo;");
      }
      e.preventDefault();
    });
  }

  Danbooru.Post.open_edit_dialog = function() {
    var $tag_string = $("#post_tag_string,#upload_tag_string");
    $("div.input").has($tag_string).prevAll().hide();
    $("#open-edit-dialog").hide();

    $("#toggle-related-tags-link").show().click();

    var dialog = $("<div/>").attr("id", "edit-dialog");
    $("#form").appendTo(dialog);
    dialog.dialog({
      title: "Edit tags",
      width: $(window).width() / 3,
        position: {
          my: "right",
          at: "right-20",
          of: window
        },
      drag: function(e, ui) {
        if (Danbooru.meta("enable-auto-complete") === "true") {
          $tag_string.data("uiAutocomplete").close();
        }
      },
      close: Danbooru.Post.close_edit_dialog
    });
    dialog.dialog("widget").draggable("option", "containment", "none");

    var pin_button = $("<button/>").button({icons: {primary: "ui-icon-pin-w"}, label: "pin", text: false});
    pin_button.css({width: "20px", height: "20px", position: "absolute", right: "28.4px"});
    dialog.parent().children(".ui-dialog-titlebar").append(pin_button);
    pin_button.click(function(e) {
      var dialog_widget = $('.ui-dialog:has(#edit-dialog)');
      var pos = dialog_widget.offset();

      if (dialog_widget.css("position") === "absolute") {
        pos.left -= $(window).scrollLeft();
        pos.top -= $(window).scrollTop();
        dialog_widget.offset(pos).css({position:"fixed"});
        dialog.dialog("option", "resize", function() { dialog_widget.css({position:"fixed"}); });

        pin_button.button("option", "icons", {primary: "ui-icon-pin-s"});
      } else {
        pos.left += $(window).scrollLeft();
        pos.top += $(window).scrollTop();
        dialog_widget.offset(pos).css({position:"absolute"});
        dialog.dialog("option", "resize", function() {});

        pin_button.button("option", "icons", {primary: "ui-icon-pin-w"});
      }
    });

    dialog.parent().mouseout(function(e) {
      dialog.parent().css({"opacity": 0.6});
    })
    .mouseover(function(e) {
      dialog.parent().css({"opacity": 1});
    });

    $tag_string.css({"resize": "none", "width": "100%"});
    $tag_string.focus().selectEnd().height($tag_string[0].scrollHeight);

    var $image = $("#c-uploads .ui-wrapper #image, #c-uploads .ui-wrapper:has(#image)");
    $image.height($image.resizable("option", "maxHeight"));
    $image.width($image.resizable("option", "maxWidth"));
  }

  Danbooru.Post.close_edit_dialog = function(e, ui) {
    $("#form").appendTo($("#c-posts #edit,#c-uploads #a-new"));
    $("#edit-dialog").remove();
    $("#related-tags").show();
    $("#toggle-related-tags-link").html("&raquo;").hide();
    var $tag_string = $("#post_tag_string,#upload_tag_string");
    $("div.input").has($tag_string).prevAll().show();
    $("#open-edit-dialog").show();
    $tag_string.css({"resize": "", "width": ""});
  }

  Danbooru.Post.initialize_similar = function() {
    $("#similar-button").click(function(e) {
      $.post("/iqdb_queries", {"url": $("#post_source").val()}).done(function(html) {$("#iqdb-similar").html(html).show()});
      e.preventDefault();
    });
  }

  Danbooru.Post.nav_prev = function() {
    if ($("#search-seq-nav").length) {
      var href = $("#search-seq-nav a[rel=prev]").attr("href");
      if (href) {
        location.href = href;
      }
    } else {
      var href = $("#pool-nav a.active[rel=prev]").attr("href");
      if (href) {
        location.href = href;
      }
    }
  }

  Danbooru.Post.nav_next = function() {
    if ($("#search-seq-nav").length) {
      var href = $("#search-seq-nav a[rel=next]").attr("href");
      location.href = href;
    } else {
      var href = $("#pool-nav a.active[rel=next]").attr("href");
      if (href) {
        location.href = href;
      }
    }
  }

  Danbooru.Post.initialize_shortcuts = function() {
    if ($("#a-show").length) {
      $(document).bind("keypress", "e", function(e) {
        $("#post-edit-link").trigger("click");
        $("#post_tag_string").focus();
        e.preventDefault();
      });

      $(document).bind("keypress", "a", function(e) {
        Danbooru.Post.nav_prev();
        e.preventDefault();
      });

      $(document).bind("keypress", "d", function(e) {
        Danbooru.Post.nav_next();
        e.preventDefault();
      });

      $(document).bind("keypress", "f", function(e) {
        if ($("#add-to-favorites").is(":visible")) {
          $("#add-to-favorites").click();
        } else {
          Danbooru.notice("You have already favorited this post")
        }
        e.preventDefault();
      });
    }
  }

  Danbooru.Post.initialize_links = function() {
    $("#side-edit-link").click(function(e) {
      $("#post-edit-link").trigger("click");
      $("#post_tag_string").trigger("focus");
      e.preventDefault();
    });

    $("#copy-notes").click(function(e) {
      var current_post_id = $("meta[name=post-id]").attr("content");
      var other_post_id = parseInt(prompt("Enter the ID of the post to copy all notes to:"), 10);

      if (other_post_id !== null) {
        $.ajax("/posts/" + current_post_id + "/copy_notes", {
          type: "PUT",
          data: {
            other_post_id: other_post_id
          },
          success: function(data) {
            Danbooru.notice("Successfully copied notes to <a href='" + other_post_id + "'>post #" + other_post_id + "</a>");
          },
          error: function(data) {
            if (data.status === 404) {
              Danbooru.error("Error: Invalid destination post");
            } else if (data.responseJSON && data.responseJSON.reason) {
              Danbooru.error("Error: " + data.responseJSON.reason);
            } else {
              Danbooru.error("There was an error copying notes to <a href='" + other_post_id + "'>post #" + other_post_id + "</a>");
            }
          }
        });
      }

      e.preventDefault();
    });

    $(".unvote-post-link").hide();
  }

  Danbooru.Post.initialize_post_relationship_previews = function() {
    var current_post_id = $("meta[name=post-id]").attr("content");
    $("[id=post_" + current_post_id + "]").addClass("current-post");

    if (Danbooru.Cookie.get("show-relationship-previews") === "0") {
      this.toggle_relationship_preview($("#has-children-relationship-preview"), $("#has-children-relationship-preview-link"));
      this.toggle_relationship_preview($("#has-parent-relationship-preview"), $("#has-parent-relationship-preview-link"));
    }

    $("#has-children-relationship-preview-link").click(function(e) {
      Danbooru.Post.toggle_relationship_preview($("#has-children-relationship-preview"), $(this));
      e.preventDefault();
    });

    $("#has-parent-relationship-preview-link").click(function(e) {
      Danbooru.Post.toggle_relationship_preview($("#has-parent-relationship-preview"), $(this));
      e.preventDefault();
    });
  }

  Danbooru.Post.toggle_relationship_preview = function(preview, preview_link) {
    preview.toggle();
    if (preview.is(":visible")) {
      preview_link.html("&laquo; hide");
      Danbooru.Cookie.put("show-relationship-previews", "1");
    }
    else {
      preview_link.html("show &raquo;");
      Danbooru.Cookie.put("show-relationship-previews", "0");
    }
  }

  Danbooru.Post.initialize_favlist = function() {
    $("#favlist").hide();
    $("#hide-favlist-link").hide();
    var fav_count = $("#show-favlist-link").prev().text();
    if (fav_count === "0") {
      $("#show-favlist-link").hide();
    }

    $("#show-favlist-link").click(function(e) {
      $("#favlist").show();
      $(this).hide();
      $("#hide-favlist-link").show();
      e.preventDefault();
    });

    $("#hide-favlist-link").click(function(e) {
      $("#favlist").hide();
      $(this).hide();
      $("#show-favlist-link").show();
      e.preventDefault();
    });
  }

  Danbooru.Post.initialize_post_previews = function() {
    $(".post-preview").each(function(i, v) {
      Danbooru.Post.initialize_title_for(v);
    });
  }

  Danbooru.Post.initialize_title_for = function(post) {
    var $post = $(post);
    var $img = $post.find("img");
    $img.attr("title", $post.attr("data-tags") + " user:" + $post.attr("data-uploader") + " rating:" + $post.data("rating") + " score:" + $post.data("score"));
  }

  Danbooru.Post.initialize_post_image_resize_links = function() {
    $("#image-resize-link").click(function(e) {
      var $link = $(e.target);
      var $image = $("#image");
      var $notice = $("#image-resize-notice");
      $image.attr("src", $link.attr("href"));
      $image.css("opacity", "0.25");
      $image.width($image.data("original-width"));
      $image.height($image.data("original-height"));        
      $image.on("load", function() {
        $image.css("opacity", "1");
        $notice.hide();
      });
      $notice.children().eq(0).hide();
      $notice.children().eq(1).show(); // Loading message
      Danbooru.Note.Box.scale_all();
      $image.data("scale_factor", 1);
      e.preventDefault();
    });

    if ($("#image-resize-notice").length && Danbooru.meta("enable-js-navigation") === "true") {
      $(document).bind("keypress", "v", function(e) {
        if ($("#image-resize-notice").is(":visible")) {
          $("#image-resize-link").click();
        } else {
          var $image = $("#image");
          var $notice = $("#image-resize-notice");
          $image.attr("src", $("#image-container").data("large-file-url"));
          $image.css("opacity", "0.25");
          $image.width($image.data("large-width"));
          $image.height($image.data("large-height")); 
          $notice.children().eq(0).show();
          $notice.children().eq(1).hide(); // Loading message
          $image.on("load", function() {
            $image.css("opacity", "1");
            $notice.show();
          });
          Danbooru.Note.Box.scale_all();
          $image.data("scale_factor", 1);
          e.preventDefault();
        }
      });
    }
  }

  Danbooru.Post.initialize_post_image_resize_to_window_link = function() {
    $("#image-resize-to-window-link").click(function(e) {
      var $img = $("#image");

      if (($img.data("scale_factor") === 1) || ($img.data("scale_factor") === undefined)) {
        $img.data("original_width", $img.width());
        $img.data("original_height", $img.height());
        var client_width = $(window).width() - $("#sidebar").width() - 75;
        var client_height = $(window).height();

        if ($img.width() > client_width) {
          var ratio = client_width / $img.width();
          $img.data("scale_factor", ratio);
          $img.css("width", $img.width() * ratio);
          $img.css("height", $img.height() * ratio);
        }
      } else {
        $img.data("scale_factor", 1);
        $img.width($img.data("original_width"));
        $img.height($img.data("original_height"));
      }

      Danbooru.Note.Box.scale_all();
      e.preventDefault();
    });
  }

  Danbooru.Post.initialize_excerpt = function() {
    $("#excerpt").hide();

    $("#show-posts-link").click(function(e) {
      $("#show-posts-link").parent("li").addClass("active");
      $("#show-excerpt-link").parent("li").removeClass("active");
      $("#posts").show();
      $("#excerpt").hide();
      e.preventDefault();
    });

    $("#show-excerpt-link").click(function(e) {
      if ($(this).parent("li").hasClass("active")) {
        return;
      }
      $("#show-posts-link").parent("li").removeClass("active");
      $("#show-excerpt-link").parent("li").addClass("active");
      $("#posts").hide();
      $("#excerpt").show();
      e.preventDefault();
    });

    if (!$(".post-preview").length && /Nobody here but us chickens/.test($("#posts").html()) && !/Deleted posts/.test($("#related-box").html())) {
      $("#show-excerpt-link").click();
    }
  }

  Danbooru.Post.initialize_post_sections = function() {
    $("#post-sections li a").click(function(e) {
      if (e.target.hash === "#comments") {
        $("#comments").show();
        $("#edit").hide();
      } else if (e.target.hash === "#edit") {
        $("#edit").show();
        $("#comments").hide();
        $("#post_tag_string").focus().selectEnd().height($("#post_tag_string")[0].scrollHeight);
        $("#related-tags-button").trigger("click");
        $("#find-artist-button").trigger("click");
      }

      $("#post-sections li").removeClass("active");
      $(e.target).parent("li").addClass("active");
      e.preventDefault();
    });

    $("#post-sections li:first-child").addClass("active");
    $("#notes").hide();
    $("#edit").hide();
  }

  Danbooru.Post.notice_update = function(x) {
    if (x === "inc") {
      Danbooru.Post.pending_update_count += 1;
      Danbooru.notice("Updating posts (" + Danbooru.Post.pending_update_count + " pending)...", true);
    } else {
      Danbooru.Post.pending_update_count -= 1;

      if (Danbooru.Post.pending_update_count < 1) {
        Danbooru.notice("Posts updated");
      } else {
        Danbooru.notice("Updating posts (" + Danbooru.Post.pending_update_count + " pending)...", true);
      }
    }
  }

  Danbooru.Post.update_data = function(data) {
    var $post = $("#post_" + data.id);
    $post.attr("data-tags", data.tag_string);
    $post.data("rating", data.rating);
    $post.removeClass("post-status-has-parent post-status-has-children");
    if (data.parent_id) {
      $post.addClass("post-status-has-parent");
    }
    if (data.has_children) {
      $post.addClass("post-status-has-children");
    }
    Danbooru.Post.initialize_title_for($post);
  }

  Danbooru.Post.vote = function(score, id) {
    Danbooru.notice("Voting...");

    $.post("/posts/" + id + "/votes.js", {
       score: score
    });
  }

  Danbooru.Post.update = function(post_id, params) {
    Danbooru.Post.notice_update("inc");

    $.ajax({
      type: "PUT",
      url: "/posts/" + post_id + ".json",
      data: params,
      success: function(data) {
        Danbooru.Post.notice_update("dec");
        Danbooru.Post.update_data(data);
      },
      error: function(data) {
        Danbooru.Post.notice_update("dec");
        Danbooru.error('There was an error updating <a href="/posts/' + post_id + '">post #' + post_id + '</a>');
        $("#post_" + post_id).effect("shake", {distance: 5, times: 1}, 100);
      }
    });
  }

  Danbooru.Post.approve = function(post_id) {
    $.ajax({
      type: "POST",
      url: "/moderator/post/approval.json",
      data: {"post_id": post_id},
      dataType: "json",
      success: function(data) {
        if (!data.success) {
          Danbooru.error("Error: " + data.reason);
        } else {
          var $post = $("#post_" + post_id);
          $post.data("flags", $post.data("flags").replace(/pending/, ""));
          $post.removeClass("post-status-pending");
          Danbooru.notice("Approved post #" + post_id);
          $("#pending-approval-notice").hide();
        }
      }
    });
  }

  Danbooru.Post.save_search = function() {
    $.post(
      "/saved_searches.js",
      {"saved_search[tag_query]": $("#tags").val()}
    );
  }
})();

$(document).ready(function() {
  Danbooru.Post.initialize_all();
});
