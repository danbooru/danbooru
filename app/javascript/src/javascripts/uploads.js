let Upload = {};

Upload.IQDB_LIMIT = 5;
Upload.IQDB_MIN_SIMILARITY = 50;
Upload.IQDB_HIGH_SIMILARITY = 70;

Upload.initialize_all = function() {
  if ($("#c-uploads #a-show").length) {
    this.initialize_image();
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
  let source = $("#post_source").val();

  if (/^https?:\/\//.test(source)) {
    $.get("/iqdb_queries.js", {
      limit: Upload.IQDB_LIMIT,
      search: {
        url: source,
        similarity: Upload.IQDB_MIN_SIMILARITY,
        high_similarity: Upload.IQDB_HIGH_SIMILARITY
      }
    });
  }
}

Upload.initialize_image = function() {
  $(document).on("click.danbooru", "#image", Upload.toggle_size);
  $(document).on("click.danbooru", "#upload-image-view-small", Upload.view_small);
  $(document).on("click.danbooru", "#upload-image-view-large", Upload.view_large);
  $(document).on("click.danbooru", "#upload-image-view-full", Upload.view_full);
}

Upload.view_small = function(e) {
  $("#image").addClass("fit-width fit-height");
  $("#a-show").attr("data-image-size", "small");
  e.preventDefault();
}

Upload.view_large = function(e) {
  $("#image").removeClass("fit-height").addClass("fit-width");
  $("#a-show").attr("data-image-size", "large");
  e.preventDefault();
}

Upload.view_full = function(e) {
  $("#image").removeClass("fit-width fit-height");
  $("#a-show").attr("data-image-size", "full");
  e.preventDefault();
}

Upload.toggle_size = function(e) {
  let window_aspect_ratio = $(window).width() / $(window).height();
  let image_aspect_ratio = $("#image").width() / $("#image").height();
  let image_size = $("#a-show").attr("data-image-size");

  if (image_size === "small" && image_aspect_ratio >= window_aspect_ratio) {
    Upload.view_full(e);
  } else if (image_size === "small" && image_aspect_ratio < window_aspect_ratio) {
    Upload.view_large(e);
  } else if (image_size === "large") {
    Upload.view_small(e);
  } else if (image_size === "full") {
    Upload.view_small(e);
  }
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
