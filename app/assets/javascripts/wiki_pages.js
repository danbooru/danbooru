(function() {
  Danbooru.WikiPage = {};

  Danbooru.WikiPage.initialize_all = function() {
    if ($("#c-wiki-pages").length) {
      if (Danbooru.meta("enable-tag-autocomplete") === "true") {
        $("#quick_search_title,#wiki_page_title").typeahead({
          name: "wiki_pages",
          remote: "/wiki_pages.json?search[title]=*%QUERY*",
          limit: 10,
          valueKey: "title",
          template: function(context) {
            return "<p>" + context.title.replace(/_/g, " ") + "</a></p>";
          }
        });
      }
    }
  }
})();

$(document).ready(function() {
  Danbooru.WikiPage.initialize_all();
});
