let PostFlag = {};

PostFlag.initialize_all = function() {
  if ($("#c-posts").length && $("#a-show").length) {
    this.initialize_flag();
  }
}

PostFlag.initialize_flag = function() {
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

  $('#flag-dialog form').submit(function() {
    $('#flag-dialog').dialog('close');
  });

  $("#flag").on("click.danbooru", function(e) {
    e.preventDefault();
    $("#flag-dialog").dialog("open");
  });
}

$(function() {
  PostFlag.initialize_all();
});

export default PostFlag
