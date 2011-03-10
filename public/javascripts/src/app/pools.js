(function() {
  Danbooru.Pool = {};
  
  Danbooru.Pool.initialize_all = function() {
    this.initialize_add_to_pool_link();
    this.initialize_simple_edit();
  }
  
  Danbooru.Pool.initialize_add_to_pool_link = function() {
    $("#add-to-pool-dialog").dialog({autoOpen: false});
    
    $("#c-pools-posts #a-new input[type=text]").autocomplete({
      source: function(req, resp) {
        $.getJSON(
          "/pools.json?search[name_contains]=" + req.term,
          function(data) {
            resp(data.map(function(x) {return x.pool.name;}));
          }
        );
      },
      minLength: 4,
    });
    
    $("a#pool").click(function(e) {
      e.preventDefault();
      $("#add-to-pool-dialog").dialog("open");
    });
    
    $("ul#recent-pools li").click(function(e) {
      e.preventDefault();
      $("#pool_name").val($(this).html());
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
        type: "put",
        url: e.target.action,
        data: $("#sortable").sortable("serialize") + "&" +  $(e.target).serialize()
      });
      return false;
    });
  }
})();

$(document).ready(function() {
  Danbooru.Pool.initialize_all();
});
