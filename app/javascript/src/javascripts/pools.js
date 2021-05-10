require("jquery-ui/ui/widgets/sortable");
require("jquery-ui/themes/base/sortable.css");

let Pool = {};

Pool.initialize_all = function() {
  if ($("#c-posts").length && $("#a-show").length) {
    this.initialize_add_to_pool_link();
  }

  if ($("#c-pool-orders,#c-favorite-group-orders").length) {
    this.initialize_simple_edit();
  }
}

Pool.initialize_add_to_pool_link = function() {
  $("#add-to-pool-dialog").dialog({autoOpen: false});

  $("#pool").on("click.danbooru", function(e) {
    e.preventDefault();
    $("#add-to-pool-dialog").dialog("open");
  });
}

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
