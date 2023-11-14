let IqdbQuery = {};

IqdbQuery.initialize_all = function() {
  $(document).on("click.danbooru", "a.toggle-iqdb-posts-low-similarity", function(event) {
    $(".iqdb-low-similarity").toggleClass("hidden");
    $("a.toggle-iqdb-posts-low-similarity").toggle();
    event.preventDefault();
  });
};

$(document).ready(IqdbQuery.initialize_all);
