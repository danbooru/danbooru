(function() {
  Danbooru.Artist = {};

  Danbooru.Artist.initialize_all = function() {
    if ($("#c-artists").length) {
      Danbooru.Artist.initialize_check_name_link();

      if (Danbooru.meta("enable-auto-complete") === "true") {
        Danbooru.Artist.initialize_auto_complete();
      }
    }
  }

  Danbooru.Artist.initialize_auto_complete = function() {
    $("#quick_search_name").autocomplete({
      minLength: 1,
      source: function(req, resp) {
        $.ajax({
          url: "/artists.json",
          data: {
            "search[name]": "*" + req.term + "*",
            "limit": 10
          },
          method: "get",
          success: function(data) {
            resp($.map(data, function(artist) {
              return {
                label: artist.name.replace(/_/g, " "),
                value: artist.name
              };
            }));
          }
        });
      }
    }).data("autocomplete")._renderItem = function(list, artist) {
      var $link = $("<a class='tag-type-1'></a>").text(artist.label);
      return $("<li></li>").data("item.autocomplete", artist).append($link).appendTo(list);
    }
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
