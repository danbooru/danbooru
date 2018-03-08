(function() {
  Danbooru.Artist = {};

  Danbooru.Artist.initialize_all = function() {
    if ($("#c-artists").length) {
      Danbooru.Artist.initialize_check_name();
      Danbooru.Artist.initialize_shortcuts();
    }
  }

  Danbooru.Artist.initialize_check_name = function() {
    $("#artist_name").keyup(function(e) {
      if ($("#artist_name").val().length > 0) {
        $("#check-name-result").html("");

        $.getJSON("/artists?search[name]=" + escape($("#artist_name").val()), function(data) {
          if (data.length === 0) {
            $.getJSON("/wiki_pages/" + escape($("#artist_name").val()), function(data) {
              if (data !== null) {
                $("#check-name-result").html("<a href='/wiki_pages/" + escape($("#artist_name").val()) + "'>A wiki page with this name already exists</a>. You must either move the wiki page or pick another artist name.")
              }
            });
          } else {
            $("#check-name-result").html("An artist with this name already exists.")
          }
        });
      }
    });
  }

  Danbooru.Artist.initialize_shortcuts = function() {
    if ($("#c-artists #a-show").length) {
      Danbooru.keydown("e", "edit", function(e) {
        $("#artist-edit a")[0].click();
      });

      Danbooru.keydown("shift+d", "delete", function(e) {
        $("#artist-delete a")[0].click();
      });
    }
  };
})();

$(document).ready(function() {
  Danbooru.Artist.initialize_all();
});
