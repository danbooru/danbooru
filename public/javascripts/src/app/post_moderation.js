(function() {
  Danbooru.PostModeration = {};
  
  Danbooru.PostModeration.initialize_all = function() {
    this.initialize_approve_link();
    this.initialize_disapprove_link();
    this.hide_or_show_approve_and_disapprove_links();
    this.hide_or_show_delete_and_undelete_links();
    this.initialize_delete_link();
    this.initialize_undelete_link();
  }
 
  Danbooru.PostModeration.hide_or_show_approve_and_disapprove_links = function() {
    if (Danbooru.meta("post-is-approvable") != "true") {
      $("a#approve").hide();
      $("a#disapprove").hide();
    }
  }
  
  Danbooru.PostModeration.hide_or_show_delete_and_undelete_links = function() {
    if (Danbooru.meta("post-is-deleted") == "true") {
      $("a#delete").hide();
    } else {
      $("a#undelete").hide();
    }
  }
  
  Danbooru.PostModeration.initialize_delete_link = function() {
    $("a#delete").click(function(e) {
      e.preventDefault();
      $.ajax({
        type: "post",
        url: "/post_moderation/delete.js",
        data: {
          post_id: Danbooru.meta("post-id")
        },
        beforeSend: function() {
          Danbooru.ajax_start(e.target);
        },
        complete: function() {
          Danbooru.ajax_stop(e.target);
        }
      });
    });
  }
  
  Danbooru.PostModeration.initialize_undelete_link = function() {
    $("a#undelete").click(function(e) {
      e.preventDefault();
      $.ajax({
        type: "post",
        url: "/post_moderation/undelete.js",
        data: {
          post_id: Danbooru.meta("post-id")
        },
        beforeSend: function() {
          Danbooru.ajax_start(e.target);
        },
        complete: function() {
          Danbooru.ajax_stop(e.target);
        }
      });
    });
  }
  
  Danbooru.PostModeration.initialize_disapprove_link = function() {
    $("a#disapprove").click(function(e) {
      e.preventDefault();
      $.ajax({
        type: "put",
        url: "/post_moderation/disapprove.js",
        data: {
          post_id: Danbooru.meta("post-id")
        },
        beforeSend: function() {
          Danbooru.ajax_start(e.target);
        },
        complete: function() {
          Danbooru.ajax_stop(e.target);
        }
      });
    });
  }
  
  Danbooru.PostModeration.initialize_approve_link = function() {
    $("a#approve").click(function(e) {
      e.preventDefault();
      $.ajax({
        type: "put",
        url: "/post_moderation/approve.js",
        data: {
          post_id: Danbooru.meta("post-id")
        },
        beforeSend: function() {
          Danbooru.ajax_start(e.target);
        },
        complete: function() {
          Danbooru.ajax_stop(e.target);
        }
      });
    });
  }
})();

$(document).ready(function() {
  Danbooru.PostModeration.initialize_all();
});
