(function() {
  Danbooru.Favorite = {};
  
  Danbooru.Favorite.initialize_all = function() {
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
})();

$(document).ready(function() {
  Danbooru.Favorite.initialize_all();
});
