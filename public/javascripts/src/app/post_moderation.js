(function() {
  Danbooru.PostModeration = {};
  
  Danbooru.PostModeration.initialize_all = function() {
    this.initialize_approve_link();
    this.initialize_disapprove_link();
    this.hide_or_show_approve_and_disapprove_links();
  }
 
  Danbooru.PostModeration.hide_or_show_approve_and_disapprove_links = function() {
    if ($("meta[name=post-is-approvable]").attr("content") != "true") {
      $("a#approve").hide();
      $("a#disapprove").hide();
    }
  }
  
  Danbooru.PostModeration.initialize_disapprove_link = function() {
    $("a#disapprove").click(function() {
      $.ajax({
        url: "/post_moderation/disapprove.js",
        type: "put",
        data: {
          post_id: $("meta[name=post-id]").attr("content")
        },
        beforeSend: function() {
          $("img#disapprove-wait").show();
        }
      });
    });
  }
  
  Danbooru.PostModeration.initialize_approve_link = function() {
    $("a#approve").click(function() {
      $.ajax({
        url: "/post_moderation/approve.js",
        type: "put",
        data: {
          post_id: $("meta[name=post-id]").attr("content")
        },
        beforeSend: function() {
          $("img#approve-wait").show();
        }
      });
    });
  }
})();

$(document).ready(function() {
  Danbooru.PostModeration.initialize_all();
});
