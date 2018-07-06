import Utility from './utility'

let PostModeration = {};

PostModeration.initialize_all = function() {
  if ($("#c-posts").length && $("#a-show").length) {
    this.hide_or_show_approve_and_disapprove_links();
    this.hide_or_show_delete_and_undelete_links();
  }
}

PostModeration.hide_or_show_approve_and_disapprove_links = function() {
  if (Utility.meta("post-is-approvable") !== "true") {
    $("#approve").hide();
    $("#disapprove").hide();
  }
}

PostModeration.hide_or_show_delete_and_undelete_links = function() {
  if (Utility.meta("post-is-deleted") === "true") {
    $("#delete").hide();
  } else {
    $("#undelete").hide();
  }
}

$(document).ready(function() {
  PostModeration.initialize_all();
});
