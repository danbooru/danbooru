Danbooru.SavedSearch = {};

Danbooru.SavedSearch.initialize_all = function() {
  if ($("#c-saved-searches").length) {
    Danbooru.sorttable($("#c-saved-searches table"));
  }
}

Danbooru.SavedSearch.labels = function(term) {
  return $.getJSON("/saved_searches/labels", {
    "search[label]": term + "*",
    "limit": 10
  });
}

$(Danbooru.SavedSearch.initialize_all);
