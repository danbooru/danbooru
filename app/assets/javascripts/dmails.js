(function() {
  Danbooru.Dmail = {};
  
  Danbooru.Dmail.initialize_all = function() {
    $("#c-dmails #preview").hide();
    
    this.initialize_preview_link();
  }
  
  Danbooru.Dmail.initialize_preview_link = function() {
    $("#c-dmails #preview-button").click(function(e) {
      $.ajax({
        type: "post",
        url: "/dtext_preview",
        data: {
          body: $("#dmail_body").val()
        },
        success: function(data) {
          $("#preview").html(data).show();
        }
      });
      e.preventDefault();
    });
  }
})();

$(document).ready(function() {
  Danbooru.Dmail.initialize_all();
});
