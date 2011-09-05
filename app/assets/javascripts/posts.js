(function() {
  Danbooru.Post = {};
  
  Danbooru.Post.pending_update_count = 0;
  
  Danbooru.Post.initialize_all = function() {
    this.initialize_post_sections();
    this.initialize_wiki_page_excerpt();
  }
  
  Danbooru.Post.initialize_wiki_page_excerpt = function() {
    if (Danbooru.Cookie.get("hide-wiki-page-excerpt") === "1") {
      $("#hide-wiki-page-excerpt").hide();
      $("#wiki-page-excerpt-content").hide();
    } else {
      $("#show-wiki-page-excerpt").hide();
    }
    
    $("#hide-wiki-page-excerpt").click(function() {
      $("#hide-wiki-page-excerpt").hide();
      $("#wiki-page-excerpt-content").hide();
      $("#show-wiki-page-excerpt").show();
      Danbooru.Cookie.put("hide-wiki-page-excerpt", "1");
    });
    
    $("#show-wiki-page-excerpt").click(function() {
      $("#hide-wiki-page-excerpt").show();
      $("#wiki-page-excerpt-content").show();
      $("#show-wiki-page-excerpt").hide();
      Danbooru.Cookie.put("hide-wiki-page-excerpt", "0");
    });
  }
  
  Danbooru.Post.initialize_post_sections = function() {
    $("#post-sections li a").click(function(e) {
      $("#comments").hide();
      $("#notes").hide();
      $("#edit").hide();
      $("#post-sections li").removeClass("active");
      $(e.target).parent("li").addClass("active");
      var name = e.target.hash;
      $(name).show();
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
    $post.data("tags", data.tags);
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
        Danbooru.j_alert("Error: " + data.reason);
      }
    });
  }
})();

$(document).ready(function() {
  Danbooru.Post.initialize_all();
  key('right', function(){ Danbooru.Paginator.next_page() });
  key('left', function(){ Danbooru.Paginator.prev_page() });
});
