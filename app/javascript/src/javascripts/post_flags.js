import Utility from './utility'

let PostFlag = {};

PostFlag.initialize_all = function() {
  if ($("#c-posts").length && $("#a-show").length) {
    this.initialize_flag();
    this.hide_or_show_flag_link();
  }
}

PostFlag.hide_or_show_flag_link = function() {
  if (Utility.meta("post-is-deleted") === "true") {
    $("#flag").hide();
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

  $("#flag").click(function(e) {
    e.preventDefault();
    $("#flag-dialog").dialog("open");
  });
}

$(function() {
  PostFlag.initialize_all();
});

export default PostFlag
