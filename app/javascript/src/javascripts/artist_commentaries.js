import Utility from "./utility";
import Rails from "@rails/ujs";

let ArtistCommentary = {};

ArtistCommentary.initialize_all = function() {
  if ($("#c-posts").length && $("#a-show").length) {
    if ($("#original-artist-commentary").length && $("#translated-artist-commentary").length) {
      this.initialize_commentary_display_tabs();
    }

    this.initialize_edit_commentary_dialog();
  }
}

ArtistCommentary.initialize_commentary_display_tabs = function() {
  $("#commentary-sections li a").on("click.danbooru", function(e) {
    if (e.target.hash === "#original") {
      $("#original-artist-commentary").show();
      $("#translated-artist-commentary").hide();
    } else if (e.target.hash === "#translated") {
      $("#original-artist-commentary").hide();
      $("#translated-artist-commentary").show();
    }

    $("#commentary-sections li").removeClass("active");
    $(e.target).parent("li").addClass("active");
    e.preventDefault();
  });
}

ArtistCommentary.initialize_edit_commentary_dialog = function() {
  $("#add-commentary-dialog").dialog({
    autoOpen: false,
    width: 700,
    buttons: {
      "Submit": function() {
        let form = $("#add-commentary-dialog #edit-commentary").get(0);
        Rails.fire(form, "submit");
        $(this).dialog("close");
      },
      "Cancel": function() {
        $(this).dialog("close");
      }
    }
  });

  $('#add-commentary-dialog #edit-commentary').submit(function() {
    $('#add-commentary-dialog').dialog('close');
  });

  $("#add-commentary").on("click.danbooru", function(e) {
    e.preventDefault();
    $("#add-commentary-dialog").dialog("open");
  });

  $('#fetch-commentary select[name="commentary_source_type"]').change(function() {
    $("#fetch-commentary input").toggle();
  });

  $('#fetch-commentary button[type="submit"]').on("click.danbooru", ArtistCommentary.fetch_commentary);
}

ArtistCommentary.fetch_commentary = function() {
  var commentary = "";
  Utility.notice("Fetching artist commentary...");

  var type = $('#fetch-commentary select[name="commentary_source_type"]').val();
  if (type === "Source") {
    var source = $('#fetch-commentary input[name="commentary_source"]').val();
    commentary = ArtistCommentary.from_source(source);
  } else if (type === "Post") {
    var id = $('#fetch-commentary input[name="commentary_post_id"]').val();
    commentary = ArtistCommentary.from_post_id(id);
  }

  commentary.then(ArtistCommentary.fill_commentary).then(function (success) {
    var message = success ? "Artist commentary copied." : "Artist commentary copied; conflicting fields ignored.";
    Utility.notice(message);
  }).catch(function () {
    Utility.notice("Fetching artist commentary failed.");
  });

  return false;
};

ArtistCommentary.from_source = function(source) {
  return $.get("/source.json?url=" + encodeURIComponent(source)).then(function(data) {
    return {
      original_title: data.artist_commentary.dtext_title,
      original_description: data.artist_commentary.dtext_description,
      source: source,
    };
  });
};

ArtistCommentary.from_post_id = function(post_id) {
  return $.get("/posts/" + encodeURIComponent(post_id) + "/artist_commentary.json").then(function(commentary) {
    commentary.source = "post #" + post_id;
    return commentary;
  });
};

ArtistCommentary.fill_commentary = function(commentary) {
  var description = ArtistCommentary.merge_commentaries($("#artist_commentary_original_description").val().trim(), commentary);
  $("#artist_commentary_original_description").val(description);

  // Update the other fields if they're blank. Return success if none conflict.
  return [
    ArtistCommentary.update_field($("#artist_commentary_original_title"), commentary.original_title),
    ArtistCommentary.update_field($("#artist_commentary_translated_title"), commentary.translated_title),
    ArtistCommentary.update_field($("#artist_commentary_translated_description"), commentary.translated_description),
  ].every(function (i) { return i; });
};

// If the new description conflicts with the current description, merge them
// by appending the new description onto the old one.
ArtistCommentary.merge_commentaries = function(description, commentary) {
  var post_source = $('.image-container').data().source;
  var normalized_source = $(".image-container").data().normalizedSource;

  if ((commentary.original_description && description) &&
      (commentary.original_description !== description)) {
    return description
      + "\n\n[tn]\nSource: " + normalized_source + "\n[/tn]"
      + "\n\nh6. " + (commentary.original_title || "Untitled")
      + "\n\n" + commentary.original_description
      + "\n\n[tn]\nSource: " + commentary.source + "\n[/tn]";
  } else if (commentary.source !== post_source) {
    return commentary.original_description + "\n\n[tn]\nSource: " + commentary.source + "\n[/tn]";
  } else {
    return commentary.original_description || description;
  }
};

// Update commentary field if it's blank, signal an error if there's a conflict.
ArtistCommentary.update_field = function($field, value) {
  if ($field.val().trim() === "") {
    $field.val(value);
    return true;
  } else if ($field.val().trim() !== value) {
    $field.effect("shake", { direction: "up", distance: 5 });
    return false;
  } else {
    return true;
  }
}

$(function() {
  ArtistCommentary.initialize_all();
});

export default ArtistCommentary
