import Post from './posts.js.erb'
import Utility from './utility'

let Favorite = {}

Favorite.initialize_all = function() {
  if ($("#c-posts").length) {
    this.hide_or_show_add_to_favorites_link();
  }
}

Favorite.hide_or_show_add_to_favorites_link = function() {
  var current_user_id = Utility.meta("current-user-id");
  if (current_user_id === "") {
    $("#add-to-favorites").hide();
    $("#remove-from-favorites").hide();
    $("#add-fav-button").hide();
    $("#remove-fav-button").hide();
    return;
  }
  if ($("#image-container").length && $("#image-container").data("is-favorited") === true) {
    $("#add-to-favorites").hide();
    $("#add-fav-button").hide();
  } else {
    $("#remove-from-favorites").hide();
    $("#remove-fav-button").hide();
  }
}

Favorite.create = function(post_id) {
  Post.notice_update("inc");

  $.ajax({
    type: "POST",
    url: "/favorites.js",
    data: {
      post_id: post_id
    },
    complete: function() {
      Post.notice_update("dec");
    },
    error: function(data, status, xhr) {
      Utility.notice("Error: " + data.reason);
    }
  });
}

Favorite.destroy = function(post_id) {
  Post.notice_update("inc");

  $.ajax({
    type: "DELETE",
    url: "/favorites/" + post_id + ".js",
    complete: function() {
      Post.notice_update("dec");
    }
  });
}

$(document).ready(function() {
  Favorite.initialize_all();
});

export default Favorite

