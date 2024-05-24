import Cookie from './cookie'

let NewsUpdate = {};

NewsUpdate.initialize = function() {
  $("#close-news-ticker-link").on("click.danbooru", function(e) {
    $("#news-updates").hide();

    var key = $("#news-updates").data("id").toString();
    Cookie.put("news-ticker", key);
  });
}

$(function() {
  NewsUpdate.initialize();
});

export default NewsUpdate
