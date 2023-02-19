import Utility from "./utility";
import Rails from "@rails/ujs";

let AIMetadata = {};

AIMetadata.initialize_all = function() {
  if ($("#c-posts").length && $("#a-show").length) {
    this.initialize_edit_ai_metadata_dialog();
  }

  if ($("#copy-as-webui").length) {
    this.initialize_copy_button();
  }
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

AIMetadata.initialize_copy_button = function() {
  $("#copy-as-webui").on("click.danbooru.ai-metadata", (e) => {
    e.preventDefault();
    let content = $("#webui-parameters").text();
    navigator.clipboard.writeText(content)
      .then(() => Utility.notice("Copied to clipboard."))
      .catch(() => Utility.error("Error copying text to clipboard."));
  });
};

AIMetadata.fetch_file_metadata = function() {
  // XXX this is ugly
  let media_asset_id = parseInt($("#post-info-size > a:nth-child(2)").attr("href").match(/\/media_assets\/(\d+)$/)[1]);
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
  // Update the other fields if they're blank. Return success if none conflict.
  return [
    Utility.update_field($("#ai_metadata_prompt"), metadata.prompt),
    Utility.update_field($("#ai_metadata_negative_prompt"), metadata.negative_prompt),
    Utility.update_field($("#ai_metadata_sampler"), metadata.sampler),
    Utility.update_field($("#ai_metadata_seed"), metadata.seed),
    Utility.update_field($("#ai_metadata_steps"), metadata.steps),
    Utility.update_field($("#ai_metadata_cfg_scale"), metadata.cfg_scale),
    Utility.update_field($("#ai_metadata_model_hash"), metadata.model_hash),
  ].every(function (i) { return i; });
};

$(function() {
  AIMetadata.initialize_all();
});

export default AIMetadata
