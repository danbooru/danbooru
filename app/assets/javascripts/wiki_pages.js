(function() {
  Danbooru.WikiPage = {};
  
  Danbooru.WikiPage.initialize_all = function() {
    $("#c-wiki-pages #preview").hide();
    
    this.initialize_preview_link();
  }
  
  Danbooru.WikiPage.initialize_preview_link = function() {
    $("#c-wiki-pages #preview a[name=toggle-preview]").click(function() {
      $("#preview").toggle();
      $("#dtext-help").toggle();
    });
    
    $("#c-wiki-pages input[value=Preview]").click(function(e) {
      e.preventDefault();
      $.ajax({
        type: "post",
        url: "/dtext/preview",
        data: {
          body: $("#wiki_page_body").val()
        },
        success: function(data) {
          $("#dtext-help").hide();
          $("#preview").show();
          $("#preview .content").html(data);
        }
      });
    });
  }
})();

$(document).ready(function() {
  Danbooru.WikiPage.initialize_all();
});
