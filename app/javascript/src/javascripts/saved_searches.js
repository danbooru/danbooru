let SavedSearch = {};

SavedSearch.initialize_all = function() {
  if ($("#c-saved-searches").length) {
    $("#c-saved-searches table").stupidtable();
  }
}

SavedSearch.labels = function(term) {
  return $.getJSON("/saved_searches/labels", {
    "search[label]": term + "*",
    "limit": 10
  });
}

$(SavedSearch.initialize_all);

export default SavedSearch
