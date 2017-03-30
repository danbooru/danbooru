(function() {
  Danbooru.Pool = {};

  Danbooru.Pool.initialize_all = function() {
    if ($("#c-pools").length) {
      this.initialize_shortcuts();
      if (Danbooru.meta("enable-auto-complete") === "true") {
        this.initialize_autocomplete_for("#search_name_matches,#quick_search_name_matches");
      }
    }

    if ($("#c-posts").length && $("#a-show").length) {
      this.initialize_add_to_pool_link();
    }

    if ($("#c-pool-orders,#c-favorite-group-orders").length) {
      this.initialize_simple_edit();
    }
  }

  Danbooru.Pool.initialize_autocomplete_for = function(selector) {
    var $fields = $(selector);

    $fields.autocomplete({
      minLength: 1,
      source: function(req, resp) {
        $.ajax({
          url: "/pools.json",
          data: {
            "search[name_matches]": req.term,
            "limit": 10
          },
          method: "get",
          success: function(data) {
            resp($.map(data, function(pool) {
              return {
                label: pool.name.replace(/_/g, " "),
                value: pool.name,
                category: pool.category
              };
            }));
          }
        });
      }
    });

    var render_pool = function(list, pool) {
      var $link = $("<a/>").addClass("pool-category-" + pool.category).text(pool.label);
      return $("<li/>").data("item.autocomplete", pool).append($link).appendTo(list);
    };

    $fields.each(function(i, field) {
      $(field).data("uiAutocomplete")._renderItem = render_pool;
    });
  }

  Danbooru.Pool.initialize_add_to_pool_link = function() {
    $("#add-to-pool-dialog").dialog({autoOpen: false});

    this.initialize_autocomplete_for("#add-to-pool-dialog input[type=text]");

    $("#pool").click(function(e) {
      e.preventDefault();
      $("#add-to-pool-dialog").dialog("open");
    });

    $("#recent-pools li").click(function(e) {
      e.preventDefault();
      $("#pool_name").val($(this).html());
    });
  }

  Danbooru.Pool.initialize_shortcuts = function() {
    if ($("#c-pools #a-show").length) {
      Danbooru.keydown("e", "edit", function(e) {
        $("#pool-edit a")[0].click();
      });

      Danbooru.keydown("shift+d", "delete", function(e) {
        $("#pool-delete a")[0].click();
      });
    }
  };

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
