(function() {
  Danbooru.ModQueue = {};
  
  Danbooru.ModQueue.initialize_approve_all_button = function() {
    $("#approve-all-button").click(function(e) {
      if (!confirm("Are you sure you want to approve every post on this page?")) {
        return;
      }

      $(".approve-link").trigger("click");
      e.preventDefault();
    });
  }
  
  Danbooru.ModQueue.initialize_hide_all_button = function() {
    $("#hide-all-button").click(function(e) {
      if (!confirm("Are you sure you want to hide every post on this page?")) {
        return;
      }

      $(".disapprove-link").trigger("click");
      e.preventDefault();
    });
  }
})();

$(function() {
  if ($("#c-moderator-post-queues").length) {
    Danbooru.ModQueue.initialize_approve_all_button();
    Danbooru.ModQueue.initialize_hide_all_button();
  }
});
