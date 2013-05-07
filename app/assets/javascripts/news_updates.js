(function() {
  Danbooru.NewsUpdate = {};

  Danbooru.NewsUpdate.initialize = function() {
    var key = $("#news-updates").data("id");

    if (Danbooru.Cookie.get("news-ticker") === key) {
      $("#news-updates").hide();
    } else {
      $("#close-news-ticker-link").click(function(e) {
        $("#news-updates").hide();
        Danbooru.Cookie.put("news-ticker", key);

        // need to reset the more link
        var $site_map_link = $("#site-map-link");
        $("#more-links").hide().offset({top: $site_map_link.offset().top + $site_map_link.height() + 10, left: $site_map_link.offset().left});

        return false;
      });
    }
  }
})();

$(function() {
  Danbooru.NewsUpdate.initialize();
});
