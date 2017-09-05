(function() {
  Danbooru.Favorite = {};

  Danbooru.Favorite.initialize_all = function() {
    if ($("#c-posts").length) {
      this.hide_or_show_add_to_favorites_link();
    }
  }

  Danbooru.Favorite.hide_or_show_add_to_favorites_link = function() {
    var favorites = Danbooru.meta("favorites");
    var current_user_id = Danbooru.meta("current-user-id");
    if (current_user_id == "") {
      $("#add-to-favorites").hide();
      $("#remove-from-favorites").hide();
      $("#add-fav-button").hide();
      $("#remove-fav-button").hide();
      return;
    }
    var regexp = new RegExp("\\bfav:" + current_user_id + "\\b");
    if ((favorites != undefined) && (favorites.match(regexp))) {
      $("#add-to-favorites").hide();
      $("#add-fav-button").hide();
    } else {
      $("#remove-from-favorites").hide();
      $("#remove-fav-button").hide();
    }
  }

  Danbooru.Favorite.create = function(post_id) {
    Danbooru.Post.notice_update("inc");

    $.ajax({
      type: "POST",
      url: "/favorites",
      data: {
        post_id: post_id
      },
      complete: function() {
        Danbooru.Post.notice_update("dec");
      },
      error: function(data, status, xhr) {
        Danbooru.notice("Error: " + data.reason);
      }
    });
  }

  Danbooru.Favorite.destroy = function(post_id) {
    Danbooru.Post.notice_update("inc");

    $.ajax({
      type: "DELETE",
      url: "/favorites/" + post_id,
      complete: function() {
        Danbooru.Post.notice_update("dec");
      }
    });
  }
})();

$(document).ready(function() {
  Danbooru.Favorite.initialize_all();
});
