(function() {
  Danbooru.JanitorTrials = {};

  Danbooru.JanitorTrials.initialize_all = function() {
    $("#c-janitor-trials input[value=Test]").click(function(e) {
      $.ajax({
        type: "get",
        url: "/janitor_trials/test.json",
        data: {
          janitor_trial: {
            user_name: $("#janitor_trial_user_name").val()
          }
        },
        success: function(data) {
          $("#test-results").html(data);
        }
      });
      
      e.preventDefault();
    });
  }
})();


$(document).ready(function() {
  Danbooru.JanitorTrials.initialize_all();
});
