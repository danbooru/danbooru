let SavedSearch = {};

SavedSearch.initialize_all = function() {
  if ($("#c-saved-searches").length) {
    $("#c-saved-searches table").stupidtable();
  }
}

$(SavedSearch.initialize_all);

export default SavedSearch
