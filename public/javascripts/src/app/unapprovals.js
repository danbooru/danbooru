(function() {
  Danbooru.Unapproval = {};
  
  Danbooru.Unapproval.initialize_all = function() {
    this.initialize_unapprove();
  }
  
  Danbooru.Unapproval.initialize_unapprove = function() {
    $("#unapprove-dialog").dialog({
      autoOpen: false, 
      width: 400,
      modal: true,
      buttons: {
        "Submit": function() {
          $("#unapprove-dialog form").submit();
        },
        "Cancel": function() {
          $(this).dialog("close");
        }
      }
    });

    $("a#unapprove").click(function() {
      $("#unapprove-dialog").dialog("open");
      return false;
    });
  }
})();

$(document).ready(function() {
  Danbooru.Unapproval.initialize_all();
});
