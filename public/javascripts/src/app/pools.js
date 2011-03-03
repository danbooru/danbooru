(function() {
  Danbooru.Pool = {};
  
  Danbooru.Pool.initialize_all = function() {
    this.initialize_add_to_pool_link();
    this.initialize_simple_edit();
  }
  
  Danbooru.Pool.initialize_add_to_pool_link = function() {
    $("#add-to-pool-dialog").dialog({autoOpen: false});
    
    $("a#pool").click(function() {
      $("#add-to-pool-dialog").dialog("open");
      return false;
    });
  }
  
  Danbooru.Pool.initialize_simple_edit = function() {
    $("ul#sortable").sortable({
      placeholder: "ui-state-placeholder"
    });
    $("ul#sortable").disableSelection();
    $("ul#sortable span.delete").click(function(e) {
      $(e.target).parent().remove();
    });
    
    $("div.pools div.edit form#ordering-form").submit(function(e) {
      $.ajax({
        url: e.target.action,
        type: "put",
        data: $("#sortable").sortable("serialize") + "&" +  $(e.target).serialize()
      });
      return false;
    });
  }
})();

$(document).ready(function() {
  Danbooru.Pool.initialize_all();
});
