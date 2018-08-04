import Cookie from './cookie'

let NewsUpdate = {};

NewsUpdate.initialize = function() {
  var key = $("#news-updates").data("id");

  if (Cookie.get("news-ticker") === key) {
    $("#news-updates").hide();
  } else {
    $("#news-updates").show();

    $("#close-news-ticker-link").click(function(e) {
      $("#news-updates").hide();
      Cookie.put("news-ticker", key);

      // need to reset the more link
      var $site_map_link = $("#site-map-link");
      $("#more-links").hide().offset({top: $site_map_link.offset().top + $site_map_link.height() + 10, left: $site_map_link.offset().left});

      return false;
    });
  }
}

$(function() {
  NewsUpdate.initialize();
});

export default NewsUpdate
