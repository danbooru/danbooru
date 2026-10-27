import Utility from './utility'

let ModQueue = {};

ModQueue.detailed_rejection_dialog = function() {
  let $link = $(this);
  let $form = $("#detailed-rejection-dialog").find("form");
  $form[0].reset();

  $("#post_disapproval_post_id").val($link.data("post-id"));
  $("#post_disapproval_reason").val($link.data("reason") || "disinterest");
  $("#post_disapproval_message").val($link.data("message") || "")[0].dispatchEvent(new Event("input"));

  let editing = Boolean($link.data("reason"));
  let label = editing ? "Update" : "Reject";
  $form.find("[type=submit]").val(label).attr("data-disable-with", label);

  Utility.dialog(editing ? "Edit rejection" : "Detailed Rejection", "#detailed-rejection-dialog");
  return false;
}

$(function() {
  $(document).on("click.danbooru", ".detailed-rejection-link", ModQueue.detailed_rejection_dialog);
});

export default ModQueue
