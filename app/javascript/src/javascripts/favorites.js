import Post from './posts.js.erb'
import Utility from './utility'

let Favorite = {}

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

export default Favorite

