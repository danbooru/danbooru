(function() {
  Danbooru.NewsUpdate = {};
  
  Danbooru.NewsUpdate.initialize = function() {
    var key = $("#news-updates").data("updated-at");
    
    if (Danbooru.Cookie.get("news-ticker") === key) {
      $("#news-updates").hide();
    } else {
      $("#close-news-ticker-link").click(function(e) {
        $("#news-updates").hide();
        Danbooru.Cookie.put("news-ticker", key);
        
        // need to reset the more link
        $("#more-links").hide().offset({top: $("#site-map-link").offset().top + $("#site-map-link").height() + 10, left: $("#site-map-link").offset().left});  
        
        return false;
      });
    }
  }
  
  $(function() {
    Danbooru.NewsUpdate.initialize();
  });
})();
