import Utility from "./utility";

let Artist = {};

Artist.initialize_all = function() {
  if ($("#c-artists").length) {
    Artist.initialize_check_name();
    Artist.initialize_shortcuts();
  }
}

Artist.initialize_check_name = function() {
  $("#artist_name").keyup(function(e) {
    if ($("#artist_name").val().length > 0) {
      $("#check-name-result").html("");

      $.getJSON("/artists?search[name]=" + escape($("#artist_name").val()), function(artists) {
        if (artists.length === 0) {
          $.getJSON("/wiki_pages/" + escape($("#artist_name").val()), function(wiki_pages) {
            if (wiki_pages !== null) {
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

Artist.initialize_shortcuts = function() {
  if ($("#c-artists #a-show").length) {
    Utility.keydown("e", "edit", function(e) {
      $("#artist-edit a")[0].click();
    });

    Utility.keydown("shift+d", "delete", function(e) {
      $("#artist-delete a")[0].click();
    });
  }
};

$(document).ready(function() {
  Artist.initialize_all();
});

export default Artist
