(function() {
  Danbooru.Post = {};
  
  Danbooru.Post.pending_update_count = 0;
  
  Danbooru.Post.initialize_all = function() {
    this.initialize_titles();
    
    if ($("#c-posts").length) {
      this.initialize_shortcuts();
    }
    
    if ($("#c-posts").length && $("#a-index").length) {
      this.initialize_wiki_page_excerpt();
    }

    if ($("#c-posts").length && $("#a-show").length) {
      this.initialize_resize_links();
      this.initialize_links();
      this.initialize_post_sections();
      this.initialize_post_image_resize_links();
      this.initialize_image_resize();
    }
  }
  
  Danbooru.Post.initialize_shortcuts = function() {
    key('/', function(e) {
      $("#tags").trigger("focus"); 
      e.preventDefault();
    });
    
    if ($("#a-show").length) {
      key('e', function(e) {
        $("#post-edit-link").trigger("click");
        $("#post_tag_string").trigger("focus");
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
  }
  
  Danbooru.Post.initialize_resize_links = function() {
    $("#resize-links").hide();

    $("#resize-links a").click(function(e) {
      var image = $("#image");
      var target = $(e.target);
      image.attr("src", target.data("src"));
      image.attr("width", target.data("width"));
      image.attr("height", target.data("height"));
      e.preventDefault();
    }); 
    
    $("#resize-link a").click(function(e) {
      $("#resize-links").toggle();
      e.preventDefault();
    });
  }
  
  Danbooru.Post.initialize_titles = function() {
    $(".post-preview").each(function(i, v) {
      Danbooru.Post.initialize_title_for(v);
    });
  }
  
  Danbooru.Post.initialize_title_for = function(post) {
    var $post = $(post);
    $post.attr("title", $post.data("tags") + " uploader:" + $post.data("uploader") + " rating:" + $post.data("rating"));
    
    var status = $post.data("flags");
    
    if (status.match(/pending/)) {
      $post.addClass("post-status-pending");
    }
    
    if (status.match(/flagged/)) {
      $post.addClass("post-status-flagged");
    }
    
    if ($post.data("parent-id")) {
      $post.addClass("post-status-has-parent");
    }

    if ($post.data("has-children")) {
      $post.addClass("post-status-has-children");
    }
  }
  
  Danbooru.Post.initialize_image_resize = function() {
    var default_image_size = Danbooru.meta("default-image-size");
    var original_width = parseInt($("#image").data("original-width"));
    var medium_width = parseInt(Danbooru.meta("config-medium-width"));
    var large_width = parseInt(Danbooru.meta("config-large-width"));

    if ((default_image_size === "medium") && (original_width > medium_width)) {
      $("#medium-file-link").trigger("click");
    } else if ((default_image_size === "large") && (original_width > large_width)) {
      $("#large-file-link").trigger("click");
    } else {
      $("#original-file-link").trigger("click");
    }
  }
  
  Danbooru.Post.build_resize_function = function(size) {
    return function(e) {
      Danbooru.Note.Box.descale_all();
      var $link = $(e.target);
      var $image = $("#image");
      $("#medium-file-link").removeClass("active");
      $("#large-file-link").removeClass("active");
      $("#original-file-link").removeClass("active");
      $link.addClass("active");
      $image.attr("src", $link.attr("href"));
      $image.width($image.data(size + "-width"));
      $image.height($image.data(size + "-height"));
      Danbooru.Note.Box.scale_all();
      e.preventDefault();
    }
  }
  
  Danbooru.Post.initialize_post_image_resize_links = function() {
    $("#medium-file-link").click(Danbooru.Post.build_resize_function("medium"));
    $("#large-file-link").click(Danbooru.Post.build_resize_function("large"));
    $("#original-file-link").click(Danbooru.Post.build_resize_function("original"));
  }
  
  Danbooru.Post.initialize_wiki_page_excerpt = function() {
    $("#wiki-page-excerpt").hide();
    
    $("#show-posts-link").click(function(e) {
      $("#show-posts-link").parent("li").addClass("active");
      $("#show-wiki-excerpt-link").parent("li").removeClass("active");
      $("#posts").show();
      $("#wiki-page-excerpt").hide();
      e.preventDefault();
    });
    
    $("#show-wiki-excerpt-link").click(function(e) {
      $("#show-posts-link").parent("li").removeClass("active");
      $("#show-wiki-excerpt-link").parent("li").addClass("active");
      $("#posts").hide();
      $("#wiki-page-excerpt").show();
      e.preventDefault();
    });
  }
  
  Danbooru.Post.initialize_post_sections = function() {
    $("#post-sections li a").click(function(e) {
      if (e.target.hash === "#comments") {
        $("#comments").fadeIn("fast");
        $("#edit").hide();
      } else {
        $("#edit").fadeIn("fast");
        $("#comments").hide();
      }
      
      $("#post-sections li").removeClass("active");
      $(e.target).parent("li").addClass("active");
      var name = e.target.hash;
      e.preventDefault();
    });
    
    $("#post-sections li:first-child").addClass("active");
    $("#notes").hide();
    $("#edit").hide();
  }
  
  Danbooru.Post.notice_update = function(x) {
    if (x === "inc") {
      Danbooru.Post.pending_update_count += 1;
      Danbooru.notice("Updating posts (" + Danbooru.Post.pending_update_count + " pending)...");
    } else {
      Danbooru.Post.pending_update_count -= 1;
      
      if (Danbooru.Post.pending_update_count < 1) {
        Danbooru.notice("Posts updated");
      } else {
        Danbooru.notice("Updating posts (" + Post.pending_update_count + " pending)...");
      }
    }
  }
  
  Danbooru.Post.update_data = function(data) {
    var $post = $("#post_" + data.id);
    $post.data("tags", data.tag_string);
    $post.data("rating", data.rating);
    Danbooru.Post.initialize_title_for($post);
  }
  
  Danbooru.Post.vote = function(score, id) {
    Danbooru.Post.notice_update("inc");
    
    $.ajax({
      type: "POST",
      url: "/posts/" + id + "/votes",
      data: {
        score: score
      },
      complete: function() {
        Danbooru.Post.notice_update("dec");
      },
      success: function(data, status, xhr) {
        $("post-score-" + data.post_id).html(data.score);
      },
      error: function(data, status, xhr) {
        Danbooru.notice("Error: " + data.reason);
      }
    });
  }
  
  Danbooru.Post.update = function(post_id, params) {
    Danbooru.Post.notice_update("inc");

    $.ajax({
      type: "PUT",
      url: "/posts/" + post_id + ".json",
      data: params,
      complete: function() {
        Danbooru.Post.notice_update("dec");
      },
      success: function(data, status, xhr) {
        Danbooru.Post.update_data(data);
        
      },
      error: function(data, status, xhr) {
        Danbooru.notice("Error: " + data.reason);
        $("#post_" + data.id).effect("shake", {"distance": 20}, "fast");
      }
    });
  }
})();

$(document).ready(function() {
  Danbooru.Post.initialize_all();
});
