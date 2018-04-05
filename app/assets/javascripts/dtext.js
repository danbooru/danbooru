(function() {
  Danbooru.Dtext = {};

  Danbooru.Dtext.initialize_all = function() {
    Danbooru.Dtext.initialize_links();
    Danbooru.Dtext.initialize_expandables();
  }

  Danbooru.Dtext.initialize_links = function() {
    $(".simple_form .dtext-preview").hide();
    $(".simple_form input[value=Preview]").click(Danbooru.Dtext.click_button);
  }

  Danbooru.Dtext.initialize_expandables = function($parent) {
    $parent = $parent || $(document);
    $parent.find(".expandable-content").hide();
    $parent.find(".expandable-button").click(function(e) {
      var button = $(this);
      button.parent().next().fadeToggle("fast");
      if (button.val() === "Show") {
        button.val("Hide");
      } else {
        button.val("Show");
      }
    });
  }

  Danbooru.Dtext.call_preview = function(e, $button, $input, $preview, inline) {
    $button.val("Edit");
    $input.hide();
    $preview.text("Loading...").fadeIn("fast");
    $.ajax({
      type: "post",
      url: "/dtext_preview",
      data: {
        body: $input.val(),
        inline: inline
      },
      success: function(data) {
        $preview.html(data).fadeIn("fast");
        Danbooru.Dtext.initialize_expandables($preview);
      }
    });
  }

  Danbooru.Dtext.call_edit = function(e, $button, $input, $preview) {
    $button.val("Preview");
    $preview.hide();
    $input.slideDown("fast");
  }

  Danbooru.Dtext.click_button = function(e) {
    var $button = $(e.target);
    var $input = $("#" + $button.data("input-id"));
    var $preview = $("#" + $button.data("preview-id"));
    var inline = $button.data("inline");

    if ($button.val().match(/preview/i)) {
      Danbooru.Dtext.call_preview(e, $button, $input, $preview, inline);
    } else {
      Danbooru.Dtext.call_edit(e, $button, $input, $preview);
    }

    e.preventDefault();
  }
})();

$(document).ready(function() {
  Danbooru.Dtext.initialize_all();
});
