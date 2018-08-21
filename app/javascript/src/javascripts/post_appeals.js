let PostAppeal = {};

PostAppeal.initialize_all = function() {
  if ($("#c-posts").length && $("#a-show").length) {
    this.initialize_appeal();
  }
}

PostAppeal.initialize_appeal = function() {
  $("#appeal-dialog").dialog({
    autoOpen: false,
    width: 700,
    modal: true,
    buttons: {
      "Submit": function() {
        $("#appeal-dialog form").submit();
        $(this).dialog("close");
      },
      "Cancel": function() {
        $(this).dialog("close");
      }
    }
  });

  $("#appeal").click(function(e) {
    e.preventDefault();
    $("#appeal-dialog").dialog("open");
  });
}

$(document).ready(function() {
  PostAppeal.initialize_all();
});

export default PostAppeal
