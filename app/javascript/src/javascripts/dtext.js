let Dtext = {};

Dtext.initialize_all = function() {
  Dtext.initialize_links();
  Dtext.initialize_expandables();
}

Dtext.initialize_links = function() {
  $(document).on("click.danbooru", ".dtext-preview-button", Dtext.click_button);
}

Dtext.initialize_expandables = function() {
  $(document).on("click.danbooru", ".expandable-button", function(e) {
    var button = $(this);
    button.parent().next().fadeToggle("fast");
    if (button.val() === "Show") {
      button.val("Hide");
    } else {
      button.val("Show");
    }
  });
}

Dtext.call_preview = async function(e, $button, $input, $preview) {
  $button.val("Edit");
  $input.hide();
  $preview.text("Loading...").fadeIn("fast");

  let inline = $input.is("input");
  let html = await $.post("/dtext_preview", { body: $input.val(), inline: inline });
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
  var $inputContainer = $form.find(`div.input.${fieldName} .dtext-previewable`);
  var $input = $inputContainer.find("> input, > textarea");
  var $preview = $inputContainer.find("div.dtext-preview");

  if ($button.val().match(/preview/i)) {
    Dtext.call_preview(e, $button, $input, $preview);
  } else {
    Dtext.call_edit(e, $button, $input, $preview);
  }

  e.preventDefault();
}

$(document).ready(function() {
  Dtext.initialize_all();
});

export default Dtext
