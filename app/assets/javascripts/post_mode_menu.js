(function() {
  Danbooru.PostModeMenu = {};
  
  Danbooru.PostModeMenu.initialize = function() {
    this.initialize_selector();
    this.initialize_preview_link();
  }
  
  Danbooru.PostModeMenu.initialize_selector = function() {
    if (Danbooru.Cookie.get("mode") === "") {
      Danbooru.Cookie.put("mode", "view");
      $("#mode-box select").val("view");
    } else {
      $("#mode-box select").val(Danbooru.Cookie.get("mode"));
    }

    $("#mode-box select").click(Danbooru.PostModeMenu.change);
  }
  
  Danbooru.PostModeMenu.initialize_preview_link = function() {
    $(".post-preview a").click(Danbooru.PostModeMenu.click);
  }
  
  Danbooru.PostModeMenu.change = function() {
    var s = $("#mode-box select").val();
    var $body = $(document.body);
    $body.removeClass();
    $body.addClass("mode-" + s);
    Danbooru.Cookie.put("mode", s, 7);

    if (s === "edit-tag-script") {
      var script = Danbooru.Cookie.get("tag-script");
      script = prompt("Enter a tag script", script);
    
      if (script) {
        Cookie.put("tag-script", script);
        $("#mode-box select").val("apply-tag-script");
      } else {
        $("#mode-box select").val("view");
      }

      this.change();
    }
  }
  
  Danbooru.PostModeMenu.click = function(e) {
    var s = $("#mode-box select").val();
    var post_id = $(e.target).closest("article").data("id");
    
    if (s === "add-fav") {
      Danbooru.Favorite.create(post_id);
    } else if (s === "remove-fav") {
      Danbooru.Favorite.destroy(post_id);
    } else if (s === "edit") {
     // TODO
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
    } else if (s === "apply-tag-script") {
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
