import Utility from './utility'

let ModQueue = {};

ModQueue.detailed_rejection_dialog = function() {
  $("#post_disapproval_post_id").val($(this).data("post-id"));
  $("#detailed-rejection-dialog").find("form")[0].reset();

  Utility.dialog("Detailed Rejection", "#detailed-rejection-dialog");
  return false;
}

$(function() {
  $(document).on("click.danbooru", ".detailed-rejection-link", ModQueue.detailed_rejection_dialog);
});

export default ModQueue
