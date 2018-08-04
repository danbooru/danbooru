import Utility from './utility'

let SavedSearch = {};

SavedSearch.initialize_all = function() {
  if ($("#c-saved-searches").length) {
    Utility.sorttable($("#c-saved-searches table"));
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
