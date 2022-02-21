import Utility from "./utility";

let Upload = {};

Upload.IQDB_LIMIT = 5;
Upload.IQDB_MIN_SIMILARITY = 50;
Upload.IQDB_HIGH_SIMILARITY = 70;

Upload.initialize_all = function() {
  if ($("#c-uploads #a-show #p-single-asset-upload").length) {
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

  Upload.loadAssets();
}

Upload.loadAssets = async function() {
  while ($(".upload-media-asset-loading").length) {
    let ids = $(".upload-media-asset-loading").map((i, el) => $(el).attr("data-id")).toArray().join(",");
    let size = $(".upload-media-asset-gallery").attr("data-size");
    $.get("/upload_media_assets.js", { search: { status: "active failed", id: ids }, size: size });
    await Utility.delay(250);
  }
}

Upload.initialize_similar = function() {
  let media_asset_id = $("input[name='media_asset_id']").val();

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

$(function() {
  Upload.initialize_all();
});

export default Upload
