(function() {
  Danbooru.Artist = {};

  Danbooru.Artist.initialize_all = function() {
    if ($("#c-artists").length) {
      Danbooru.Artist.initialize_check_name_link();

      if (Danbooru.meta("enable-auto-complete") === "true") {
        Danbooru.Artist.initialize_autocomplete();
      }
    }
  }

  Danbooru.Artist.initialize_autocomplete = function() {
    var $fields = $("#search_name,#quick_search_name");

    $fields.autocomplete({
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
    });

    var render_artist = function(list, artist) {
      var $link = $("<a/>").addClass("tag-type-1").text(artist.label);
      return $("<li/>").data("item.autocomplete", artist).append($link).appendTo(list);
    };

    $fields.each(function(i, field) {
      $(field).data("uiAutocomplete")._renderItem = render_artist;
    });
  }

  Danbooru.Artist.initialize_check_name_link = function() {
    $("#check-name-link").click(function(e) {
      var artist_name = $("#artist_name").val();

      if (artist_name.length === 0) {
        $("#check-name-result").html("OK");
      }

      $.get("/artists.json?name=" + artist_name,
        function(artists) {
          $("check-name-result").empty();

          if (artists.length) {
            $("#check-name-result").text("Taken: ");

            $.map(artists.slice(0, 5), function (artist) {
              var link = $("<a>").attr("href", "/artists/" + artist.id).text(artist.name);
              $("#check-name-result").append(link);
            });
          } else {
            $("#check-name-result").text("OK");
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
