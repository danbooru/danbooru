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

ModQueue.initialize_hilights = function() {
  $.each($("div.post"), function(i, v) {
    var $post = $(v);
    var score = parseInt($post.data("score"));
    if (score >= 3) {
      $post.addClass("post-pos-score");
    }
    if (score <= -3) {
      $post.addClass("post-neg-score");
    }
    if ($post.data("has-children")) {
      $post.addClass("post-has-children");
    }
  });
}

ModQueue.initialize_detailed_rejection_links = function() {
  $(".detailed-rejection-link").on("click.danbooru", ModQueue.detailed_rejection_dialog)
}

ModQueue.detailed_rejection_dialog = function() {
  $("#post_disapproval_post_id").val($(this).data("post-id"));

  $("#detailed-rejection-dialog").dialog({
    width: 500,
    buttons: {
      "Submit": function() {
        $(this).find("form").submit();
        $(this).dialog("close");
      },
      "Cancel": function() {
        $(this).dialog("close");
      }
    }
  });

  return false;
}

$(function() {
  $(window).on("danbooru:modqueue_increment_processed", ModQueue.increment_processed);

  if ($("#c-moderator-post-queues").length) {
    ModQueue.initialize_hilights();
    ModQueue.initialize_detailed_rejection_links();
  }

  if ($("#c-posts #a-show").length) {
    ModQueue.initialize_detailed_rejection_links();
  }
});

export default ModQueue
