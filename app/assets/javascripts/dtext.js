(function() {
  Danbooru.Dtext = {};
  
  Danbooru.Dtext.initialize_links = function() {
    $(".simple_form .dtext-preview").hide();
    $(".simple_form input[value=Preview]").click(Danbooru.Dtext.click_button);
  }
  
  Danbooru.Dtext.call_preview = function(e, $button, $input, $preview) {
    $.ajax({
      type: "post",
      url: "/dtext_preview",
      data: {
        body: $input.val()
      },
      success: function(data) {
        $button.val("Edit");
        $input.hide();
        $preview.html(data).show();
      }
    });
  }
  
  Danbooru.Dtext.call_edit = function(e, $button, $input, $preview) {
    $button.val("Preview");
    $preview.hide();
    $input.show();
  }
  
  Danbooru.Dtext.click_button = function(e) {
    var $button = $(e.target);
    var $input = $("#" + $button.data("input-id"));
    var $preview = $("#" + $button.data("preview-id"));
    
    if ($button.val().match(/preview/i)) {
      Danbooru.Dtext.call_preview(e, $button, $input, $preview);
    } else {
      Danbooru.Dtext.call_edit(e, $button, $input, $preview);
    }

    e.preventDefault();
  }
})();

$(document).ready(function() {
  Danbooru.Dtext.initialize_links();
});
