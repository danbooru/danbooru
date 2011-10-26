(function() {
  Danbooru.ModQueue = {};
  
  Danbooru.ModQueue.initialize_approve_all_button = function(e) {
    $("#c-moderator-post-queues #approve-all-button").click(function() {
      $(".approve-link").trigger("click");
    });
    
    e.preventDefault();
  }
  
  Danbooru.ModQueue.initialize_hide_all_button = function(e) {
    $("#c-moderator-post-queues #hide-all-button").click(function() {
      $(".disapprove-link").trigger("click");
    });
    
    e.preventDefault();
  }
})();

$(function() {
  Danbooru.ModQueue.initialize_approve_all_button();
  Danbooru.ModQueue.initialize_hide_all_button();
});
