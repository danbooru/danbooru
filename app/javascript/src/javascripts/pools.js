import Utility from './utility'

let Pool = {};

Pool.initialize_all = function() {
  if ($("#c-pools").length) {
    this.initialize_shortcuts();
  }

  if ($("#c-posts").length && $("#a-show").length) {
    this.initialize_add_to_pool_link();
  }

  if ($("#c-pool-orders,#c-favorite-group-orders").length) {
    this.initialize_simple_edit();
  }
}

Pool.initialize_add_to_pool_link = function() {
  $("#add-to-pool-dialog").dialog({autoOpen: false});

  $("#pool").click(function(e) {
    e.preventDefault();
    $("#add-to-pool-dialog").dialog("open");
  });

  $("#recent-pools li").click(function(e) {
    e.preventDefault();
    $("#pool_name").val($(this).attr("data-value"));
  });
}

Pool.initialize_shortcuts = function() {
  if ($("#c-pools #a-show").length) {
    Utility.keydown("e", "edit", function(e) {
      $("#pool-edit a")[0].click();
    });

    Utility.keydown("shift+d", "delete", function(e) {
      $("#pool-delete a")[0].click();
    });
  }
};

Pool.initialize_simple_edit = function() {
  $("#sortable").sortable({
    placeholder: "ui-state-placeholder"
  });
  $("#sortable").disableSelection();

  $("#ordering-form").submit(function(e) {
    $.ajax({
      type: "put",
      url: e.target.action,
      data: $("#sortable").sortable("serialize") + "&" + $(e.target).serialize()
    });
    e.preventDefault();
  });
}

$(document).ready(function() {
  Pool.initialize_all();
});

export default Pool
