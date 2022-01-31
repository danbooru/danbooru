let Upload = {};

Upload.IQDB_LIMIT = 5;
Upload.IQDB_MIN_SIMILARITY = 50;
Upload.IQDB_HIGH_SIMILARITY = 70;

Upload.initialize_all = function() {
  if ($("#c-uploads #a-show").length) {
    this.initialize_similar();

    $("#toggle-artist-commentary").on("click.danbooru", function(e) {
      Upload.toggle_commentary();
      e.preventDefault();
    });

    $("#toggle-commentary-translation").on("click.danbooru", function(e) {
      Upload.toggle_translation();
      e.preventDefault();
    });
  }

  if ($("#c-uploads #a-batch").length) {
    $(document).on("click.danbooru", "#c-uploads #a-batch #link", Upload.batch_open_all);
  }
}

Upload.initialize_similar = function() {
  let media_asset_id = $("input[name='post[media_asset_id]']").val();

  $.get("/iqdb_queries.js", {
    limit: Upload.IQDB_LIMIT,
    search: {
      media_asset_id: media_asset_id,
      similarity: Upload.IQDB_MIN_SIMILARITY,
      high_similarity: Upload.IQDB_HIGH_SIMILARITY
    }
  });
}

Upload.toggle_commentary = function() {
  if ($(".artist-commentary").is(":visible")) {
    $("#toggle-artist-commentary").text("show »");
  } else {
    $("#toggle-artist-commentary").text("« hide");
  }

  $(".artist-commentary").slideToggle();
  $(".upload_commentary_translation_container").slideToggle();
};

Upload.toggle_translation = function() {
  if ($(".commentary-translation").is(":visible")) {
    $("#toggle-commentary-translation").text("show »");
  } else {
    $("#toggle-commentary-translation").text("« hide");
  }

  $(".commentary-translation").slideToggle();
};

Upload.batch_open_all = function() {
  $(".upload-preview > a").each((_i, link) => window.open(link.href));
};

$(function() {
  Upload.initialize_all();
});

export default Upload
