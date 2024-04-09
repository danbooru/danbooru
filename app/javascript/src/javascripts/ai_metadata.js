import Utility from "./utility";
import Autocomplete from "./autocomplete";
import Rails from "@rails/ujs";

let AIMetadata = {};

AIMetadata.initialize_all = function() {
  if ($("#c-posts").length && $("#a-show").length) {
    this.initialize_edit_ai_metadata_dialog();
  }

  if ($("#add-field-button").length) {
    $("#add-field-button").on("click.danbooru", (e) => {
      e.preventDefault();
      AIMetadata.add_custom_field(e.target);
    });
  }

  if ($("#create-post-button").length) {
    $("#create-post-button").on("click", (_e) => {
      AIMetadata.inject_names(document);
    });
  }

  if ($(".remove-metadata-button").length) {
    $(".remove-metadata-button").on("click", (e) => {
      $(e.target).closest("div").remove();
    });
  }
};

AIMetadata.inject_names = function(form) {
  let customFields = form.querySelectorAll(".custom-metadata-field");
  customFields.forEach(el => {
    let [name, value] = el.children;
    if (name.value && value.value) {
      value.name = `ai_metadata[${name.value}]`;
    }
  });
};

AIMetadata.add_custom_field = function(el, name = "", value = "") {
  let field = $(`
    <div class="input text optional custom-metadata-field">
      <input type="text" class="ui-autocomplete-input optional custom-metadata-field-name" placeholder="Parameter name" data-autocomplete="ai-metadata-label" value="${name}">
      <input type="text" class="optional custom-metadata-field-value" placeholder="Parameter value" value="${value}">
    </div>
  `);
  let removeButton = $(`
    <span class="remove-metadata-button">
      <i>${$("#remove-metadata-row-icon").html()}</i>
    </span>
  `);
  removeButton.on("click", (e) => {
    field.remove();
  }).appendTo(field);
  field.insertBefore(el);
  Autocomplete.initialize_fields(field.children(":first-child"), "ai_metadata_label");
};

AIMetadata.initialize_edit_ai_metadata_dialog = function() {
  $("#add-ai-metadata-dialog").dialog({
    autoOpen: false,
    width: 700,
    buttons: {
      "Load from File": function() {
        AIMetadata.load_from_file();
      },
      "Submit": function() {
        let form = $("#add-ai-metadata-dialog #edit-ai-metadata").get(0);
        AIMetadata.inject_names(form);
        Rails.fire(form, "submit");
        $(this).dialog("close");
      },
      "Cancel": function() {
        $(this).dialog("close");
      }
    }
  });

  $("#add-ai-metadata-dialog #edit-ai-metadata").submit(() => {
    $("#add-ai-metadata-dialog").dialog("close");
  });

  $("#add-ai-metadata").on("click.danbooru", (e) => {
    e.preventDefault();
    $("#add-ai-metadata-dialog").dialog("open");
  });
};

AIMetadata.fetch_file_metadata = function() {
  let media_asset_id = parseInt(document.querySelector("[data-media-asset-id]").dataset["mediaAssetId"]);
  return $.get(`/media_assets/${media_asset_id}/metadata.json`);
};

AIMetadata.load_from_file = function() {
  Utility.notice("Loading metadata...");

  this.fetch_file_metadata().then(this.fill_metadata).then(function (success) {
    var message = success ? "Metadata copied." : "Metadata copied; conflicting fields ignored.";
    Utility.notice(message);
  }).catch(function () {
    Utility.notice("Loading metadata failed.");
  });

  return false;
};

AIMetadata.fill_metadata = function(metadata) {
  let el = $("#add-field-button");
  $(".custom-metadata-field").remove();
  for (const [name, value] of Object.entries(metadata.parameters)) {
    AIMetadata.add_custom_field(el, name, value)
  }
  return [
    Utility.update_field($("#ai_metadata_prompt"), metadata.prompt),
    Utility.update_field($("#ai_metadata_negative_prompt"), metadata.negative_prompt),
  ].every(i => i);
};

$(function() {
  AIMetadata.initialize_all();
});

export default AIMetadata;
