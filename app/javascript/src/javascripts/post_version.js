import Notice from './notice';

let PostVersion = {};

PostVersion.initialize_all = function() {
  if ($("#c-post-versions #a-index").length) {
    PostVersion.initialize_undo();
  }
};

PostVersion.initialize_undo = function() {
  /* Expand the clickable area of the checkbox to the entire table cell. */
  $(".post-version-select-column").on("click.danbooru", function(event) {
    $(event.target).find(".post-version-select-checkbox:not(:disabled)").prop("checked", (_, checked) => !checked).change();
  });

  $("#post-version-select-all-checkbox").on("change.danbooru", function(event) {
    $("td .post-version-select-checkbox:not(:disabled)").prop("checked", $("#post-version-select-all-checkbox").prop("checked")).change();
  });

  $(".post-version-select-checkbox").on("change.danbooru", function(event) {
    let checked = $("td .post-version-select-checkbox:checked");
    $("#subnav-undo-selected").text(`Undo selected (${checked.length})`).toggle(checked.length > 0);
  });

  $("#subnav-undo-selected").on("click.danbooru", PostVersion.undo_selected);
};

PostVersion.undo_selected = async function () {
  event.preventDefault();

  let updated = 0;
  let selected_rows = $("td .post-version-select-checkbox:checked").parents("tr");

  for (let row of selected_rows) {
    let id = $(row).data("id");
    await $.ajax(`/post_versions/${id}/undo.json`, { method: "PUT" });

    updated++;
    Notice.info(`${updated}/${selected_rows.length} changes undone.`);
  }
};

$(document).ready(PostVersion.initialize_all);
export default PostVersion;
