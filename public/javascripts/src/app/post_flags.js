(function() {
  Danbooru.PostFlag = {};
  
  Danbooru.PostFlag.initialize_all = function() {
    this.initialize_flag();
    this.hide_or_show_flag_link();
  }
  
  Danbooru.PostFlag.hide_or_show_flag_link = function() {
    if (Danbooru.meta("post-is-deleted") == "true") {
      $("a#flag").hide();
    }
  }
  
  Danbooru.PostFlag.initialize_flag = function() {
    $("#flag-dialog").dialog({
      autoOpen: false, 
      width: 700,
      modal: true,
      buttons: {
        "Submit": function() {
          $("#flag-dialog form").submit();
          $(this).dialog("close");
        },
        "Cancel": function() {
          $(this).dialog("close");
        }
      }
    });

    $("a#flag").click(function(e) {
      e.preventDefault();
      $("#flag-dialog").dialog("open");
    });
  }
})();

$(document).ready(function() {
  Danbooru.PostFlag.initialize_all();
});
