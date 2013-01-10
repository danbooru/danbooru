(function() {
  Danbooru.Pool = {};
  
  Danbooru.Pool.initialize_all = function() {
    if ($("#c-posts").length && $("#a-show").length) {
      this.initialize_add_to_pool_link();
    }
    
    if ($("#c-pool-orders").length) {
      this.initialize_simple_edit();
    }
  }
  
  Danbooru.Pool.initialize_add_to_pool_link = function() {
    $("#add-to-pool-dialog").dialog({autoOpen: false});
    
    $("#c-pool-elements #a-new input[type=text]").autocomplete({
      source: function(req, resp) {
        $.getJSON(
          "/pools.json?search[name_matches]=" + req.term,
          function(data) {
            resp(data.map(function(x) {return x.name;}));
          }
        );
      },
      minLength: 4,
    });
    
    $("#pool").click(function(e) {
      e.preventDefault();
      $("#add-to-pool-dialog").dialog("open");
    });
    
    $("#recent-pools li").click(function(e) {
      e.preventDefault();
      $("#pool_name").val($(this).html());
    });
  }
  
  Danbooru.Pool.initialize_simple_edit = function() {
    $("#sortable").sortable({
      placeholder: "ui-state-placeholder"
    });
    $("#sortable").disableSelection();
    
    $("#ordering-form").submit(function(e) {
      $.ajax({
        type: "put",
        url: e.target.action,
        data: $("#sortable").sortable("serialize") + "&" +  $(e.target).serialize()
      });
      e.preventDefault();
    });
  }
})();

$(document).ready(function() {
  Danbooru.Pool.initialize_all();
});
