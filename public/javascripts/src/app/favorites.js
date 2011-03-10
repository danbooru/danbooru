(function() {
  Danbooru.Favorite = {};
  
  Danbooru.Favorite.initialize_all = function() {
    this.initialize_add_to_favorites();
    this.initialize_remove_from_favorites();
    this.hide_or_show_add_to_favorites_link();
  }
  
  Danbooru.Favorite.hide_or_show_add_to_favorites_link = function() {
    var favorites = Danbooru.meta("favorites");
    var current_user_id = Danbooru.meta("current-user-id");
    if (current_user_id == "") {
      $("a#add-to-favorites").hide();
      $("a#remove-from-favorites").hide();
      return;
    }
    var regexp = new RegExp("\\bfav:" + current_user_id + "\\b");
    if ((favorites != undefined) && (favorites.match(regexp))) {
      $("a#add-to-favorites").hide();
    } else {
      $("a#remove-from-favorites").hide();      
    }
  }
  
  Danbooru.Favorite.initialize_add_to_favorites = function() {
    $("a#add-to-favorites").click(function(e) {
      e.preventDefault();
      
      $.ajax({
        type: "post",
        url: "/favorites",
        data: {
          id: Danbooru.meta("post-id")
        },
        beforeSend: function() {
          Danbooru.ajax_start(e.target);
        },
        success: function() {
          $("a#add-to-favorites").hide();
          $("a#remove-from-favorites").show();
        },
        complete: function() {
          Danbooru.ajax_stop(e.target);
        }
      });
    });
  }
  
  Danbooru.Favorite.initialize_remove_from_favorites = function() {
    $("a#remove-from-favorites").click(function(e) {
      e.preventDefault();
      
      $.ajax({
        type: "delete",
        url: "/favorites/" + Danbooru.meta("post-id"),
        beforeSend: function() {
          Danbooru.ajax_start(e.target);
        },
        success: function() {
          $("a#add-to-favorites").show();
          $("a#remove-from-favorites").hide();
        },
        complete: function() {
          Danbooru.ajax_stop(e.target);
        }
      });
    });
  }
})();

$(document).ready(function() {
  Danbooru.Favorite.initialize_all();
});
