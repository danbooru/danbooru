(function() {
  Danbooru.PostModeration = {};
  
  Danbooru.PostModeration.initialize_all = function() {
    this.hide_or_show_approve_and_disapprove_links();
    this.hide_or_show_delete_and_undelete_links();
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
})();

$(document).ready(function() {
  Danbooru.PostModeration.initialize_all();
});
