(function() {
  Danbooru.Artist = {};

  Danbooru.Artist.initialize_all = function() {
    if ($("#c-artists").length) {
      Danbooru.Artist.initialize_check_name_link();
      Danbooru.Artist.initialize_typeahead();
    }
  }

  Danbooru.Artist.initialize_typeahead = function() {
    $("#quick_search_name").typeahead({
      name: "artists",
      remote: "/artists.json?search[name]=*%QUERY*",
      limit: 10,
      valueKey: "name",
      template: function(context) {
        return "<p>" + context.name.replace(/_/g, " ") + "</a></p>";
      }
    });
  }

  Danbooru.Artist.initialize_check_name_link = function() {
    $("#check-name-link").click(function(e) {
      var artist_name = $("#artist_name").val();

      if (artist_name.length === 0) {
        $("#check-name-result").html("OK");
      }

      $.get("/artists.json?name=" + artist_name,
        function(data) {
          if (data.length) {
            $("#check-name-result").html("Taken");
          } else {
            $("#check-name-result").html("OK");
          }
        }
      );
      e.preventDefault();
    });
  }
})();


$(document).ready(function() {
  Danbooru.Artist.initialize_all();
});
