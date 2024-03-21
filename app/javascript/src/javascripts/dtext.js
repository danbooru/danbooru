let Dtext = {};

Dtext.initialize_all = function() {
  Dtext.initialize_links();
}

Dtext.initialize_links = function() {
  $(document).on("click.danbooru", ".dtext-preview-button", Dtext.click_button);
}

Dtext.call_preview = async function(e, $button, $input, $preview, mediaEmbeds) {
  $button.val("Edit");
  $input.hide();
  $preview.text("Loading...").fadeIn("fast");

  let inline = $input.is("input");
  let html = await $.post("/dtext_preview", { body: $input.val(), inline: inline, media_embeds: mediaEmbeds });
  $preview.html(html).fadeIn("fast");
}

Dtext.call_edit = function(e, $button, $input, $preview) {
  $button.val("Preview");
  $preview.hide();
  $input.slideDown("fast");
}

Dtext.click_button = function(e) {
  var $button = $(e.target);
  var $form = $button.parents("form");
  var fieldName = $button.data("preview-field");
  var mediaEmbeds = $button.data("media-embeds");
  var $inputContainer = $form.find(`div.input.${fieldName} .dtext-previewable`);
  var $input = $inputContainer.find("> input, > textarea");
  var $preview = $inputContainer.find("div.dtext-preview");

  if ($button.val().match(/preview/i)) {
    Dtext.call_preview(e, $button, $input, $preview, mediaEmbeds);
  } else {
    Dtext.call_edit(e, $button, $input, $preview);
  }

  e.preventDefault();
}

$(document).ready(function() {
  Dtext.initialize_all();
});

export default Dtext
