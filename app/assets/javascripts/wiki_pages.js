(function() {
  Danbooru.WikiPage = {};

  Danbooru.WikiPage.initialize_all = function() {
    if ($("#c-wiki-pages").length) {
      this.initialize_typeahead();
    }
  }

  Danbooru.WikiPage.initialize_typeahead = function() {
    if (Danbooru.meta("enable-auto-complete") === "true") {
      $("#quick_search_title,#wiki_page_title").autocomplete({
        source: function(req, resp) {
          $.ajax({
            url: "/wiki_pages.json",
            data: {
              "search[title]": "*" + req.term + "*"
            },
            method: "get",
            minLength: 2,
            success: function(data) {
              resp($.map(data, function(tag) {
                return {
                  label: tag.title.replace(/_/g, " "),
                  value: tag.title
                };
              }));
            }
          });
        }
      });
    }
  }
})();

$(document).ready(function() {
  Danbooru.WikiPage.initialize_all();
});
