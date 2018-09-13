import Post from './posts.js.erb'

let Upload = {};

Upload.initialize_all = function() {
  if ($("#c-uploads,#c-posts").length) {
    this.initialize_enter_on_tags();
    $(document).on("click.danbooru", "#fetch-data-manual", Upload.fetch_data_manual);
  }

  if ($("#c-uploads").length) {
    if ($("#image").prop("complete")) {
      this.initialize_image();
    } else {
      $("#image").on("load.danbooru error.danbooru", this.initialize_image);
    }
    this.initialize_info_bookmarklet();
    this.initialize_similar();
    this.initialize_submit();
    $(() => $("#related-tags-button").click()); // delay so we don't click until button is bound (#3895).

    $("#toggle-artist-commentary").on("click.danbooru", function(e) {
      Upload.toggle_commentary();
      e.preventDefault();
    });
  }

  if ($("#iqdb-similar").length) {
    this.initialize_iqdb_source();
  }
}

Upload.initialize_submit = function() {
  $("#form").on("submit.danbooru", Upload.validate_upload);
}

Upload.validate_upload = function (e) {
  var error_messages = [];
  if (($("#upload_file").val() === "") && ($("#upload_source").val() === "") && $("#upload_md5_confirmation").val() === "") {
    error_messages.push("Must choose file or specify source");
  }
  if (!$("#upload_rating_s").prop("checked") && !$("#upload_rating_q").prop("checked") && !$("#upload_rating_e").prop("checked") &&
      ($("#upload_tag_string").val().search(/\brating:[sqe]/i) < 0)) {
    error_messages.push("Must specify a rating");
  }
  if (error_messages.length === 0) {
    $("#submit-button").prop("disabled", "true");
    $("#submit-button").prop("value", "Submitting...");
    $("#client-errors").hide();
  } else {
    $("#client-errors").html("<strong>Error</strong>: " + error_messages.join(", "));
    $("#client-errors").show();
    e.preventDefault();
  }
}

Upload.initialize_iqdb_source = function() {
  if (/^https?:\/\//.test($("#upload_source").val())) {
    $.get("/iqdb_queries", {"url": $("#upload_source").val()}).done(function(html) {$("#iqdb-similar").html(html)});
  }
}

Upload.initialize_enter_on_tags = function() {
  var $textarea = $("#upload_tag_string, #post_tag_string");
  var $submit = $textarea.parents("form").find('input[type="submit"]');

  $textarea.on("keydown.danbooru.submit", null, "return", function(e) {
    $submit.click();
    e.preventDefault();
  });
}

Upload.initialize_similar = function() {
  $("#similar-button").on("click.danbooru", function(e) {
    $.get("/iqdb_queries", {"url": $("#upload_source").val()}).done(function(html) {$("#iqdb-similar").html(html).show()});
    e.preventDefault();
  });
}

Upload.initialize_info_bookmarklet = function() {
  $("#upload_source").on("change.danbooru", Upload.fetch_data_manual);
  $("#fetch-data-manual").click();
}

Upload.update_scale = function() {
  var $image = $("#image");
  var ratio = $image.data("scale-factor");
  if (ratio < 1) {
    $("#scale").html("Scaled " + parseInt(100 * ratio) + "% (original: " + $image.data("original-width") + "x" + $image.data("original-height") + ")");
  } else {
    $("#scale").html("Original: " + $image.data("original-width") + "x" + $image.data("original-height"));
  }
}

Upload.fetch_data_manual = function(e) {
  var url = $("#upload_source,#post_source").val();
  var ref = $("#upload_referer_url").val();

  if (/^https?:\/\//.test(url)) {
    $("#source-info").addClass("loading");
    $.get("/source.js", { url: url, ref: ref }).always(resp => $("#source-info").removeClass("loading"));
  }

  e.preventDefault();
}

Upload.initialize_image = function() {
  var $image = $("#image");
  if (!$image.length) {
    return;
  }
  var width = $image.width();
  var height = $image.height();
  if (!width || !height) {
    // try again later
    $.timeout(100).done(function() {Upload.initialize_image()});
    return;
  }
  $image.data("original-width", width);
  $image.data("original-height", height);
  Post.resize_image_to_window($image);
  Post.initialize_post_image_resize_to_window_link();
  Upload.update_scale();
  $("#image-resize-to-window-link").on("click.danbooru", Upload.update_scale);
}

Upload.toggle_commentary = function() {
  if ($(".artist-commentary").is(":visible")) {
    $("#toggle-artist-commentary").text("show »");
  } else {
    $("#toggle-artist-commentary").text("« hide");
  }

  $(".artist-commentary").slideToggle();
};

$(function() {
  Upload.initialize_all();
});

export default Upload
