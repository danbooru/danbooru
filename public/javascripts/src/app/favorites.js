(function() {
  Danbooru.Favorite = {};
  
  Danbooru.Favorite.initialize_all = function() {
    this.initialize_add_to_favorites();
    this.initialize_remove_from_favorites();
    this.hide_or_show_add_to_favorites_link();
  }
  
  Danbooru.Favorite.hide_or_show_add_to_favorites_link = function() {
    var favorites = $("meta[name=favorites]").attr("content");
    var current_user_id = $("meta[name=current-user-id]").attr("content");
    
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
      e.stopPropagation();
      
      $.ajax({
        url: "/favorites",
        data: {
          id: $("meta[name=post-id]").attr("content")
        },
        beforeSend: function() {
          $("img#add-to-favorites-wait").show();
        },
        success: function(data, text_status, xhr) {
          $("a#add-to-favorites").hide();
          $("a#remove-from-favorites").show();
          $("img#add-to-favorites-wait").hide();
        },
        type: "post"
      });
      
      return false;
    });
  }
  
  Danbooru.Favorite.initialize_remove_from_favorites = function() {
    $("a#remove-from-favorites").click(function(e) {
      e.stopPropagation();
      
      $.ajax({
        url: "/favorites/" + $("meta[name=post-id]").attr("content"),
        beforeSend: function() {
          $("img#remove-from-favorites-wait").show();
        },
        success: function(data, text_status, xhr) {
          $("a#add-to-favorites").show();
          $("a#remove-from-favorites").hide();
          $("img#remove-from-favorites-wait").hide();
        },
        type: "delete"
      });
      
      return false;
    });
  }
})();

$(document).ready(function() {
  Danbooru.Favorite.initialize_all();
});
