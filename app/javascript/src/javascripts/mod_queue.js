import Utility from './utility'

let ModQueue = {};

ModQueue.processed = 0;

ModQueue.increment_processed = function() {
  if (Utility.meta("random-mode") === "1") {
    ModQueue.processed += 1;

    if (ModQueue.processed === 12) {
      window.location = Utility.meta("return-to");
    }
  }
}

ModQueue.detailed_rejection_dialog = function() {
  $("#post_disapproval_post_id").val($(this).data("post-id"));
  $("#detailed-rejection-dialog").find("form")[0].reset();

  Utility.dialog("Detailed Rejection", "#detailed-rejection-dialog");
  return false;
}

$(function() {
  $(window).on("danbooru:modqueue_increment_processed", ModQueue.increment_processed);
  $(document).on("click.danbooru", ".quick-mod .detailed-rejection-link", ModQueue.detailed_rejection_dialog);
});

export default ModQueue
