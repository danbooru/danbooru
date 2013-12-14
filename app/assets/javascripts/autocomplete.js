(function() {
  Danbooru.Autocomplete = {};

  Danbooru.Autocomplete.initialize_all = function() {
    if (Danbooru.meta("enable-auto-complete") === "true") {
      this.initialize_tag_autocomplete();
    }
  }

  Danbooru.Autocomplete.initialize_tag_autocomplete = function() {
    var $fields_multiple = $(
      "#tags,#post_tag_string,#upload_tag_string,#tag-script-field,#c-moderator-post-queues #query"
    );
    var $fields_single = $(
      "#search_post_tags_match,#c-tags #search_name_matches,#c-tag-aliases #query,#c-tag-implications #query," +
      "#wiki_page_title,#artist_name," +
      "#tag_alias_request_antecedent_name,#tag_alias_request_consequent_name," +
      "#tag_implication_request_antecedent_name,#tag_implication_request_consequent_name," +
      "#tag_alias_antecedent_name,#tag_alias_consequent_name," +
      "#tag_implication_antecedent_name,#tag_implication_consequent_name"
    );

    var prefixes = "-|~|general:|gen:|artist:|art:|copyright:|copy:|co:|character:|char:|ch:";

    $fields_multiple.autocomplete({
      delay: 100,
      focus: function() {
        return false;
      },
      select: function(event, ui) {
        var before_caret_text = this.value.substring(0, this.selectionStart);
        var after_caret_text = this.value.substring(this.selectionStart);

        var regexp = new RegExp("(" + prefixes + ")?\\S+$", "g");
        this.value = before_caret_text.replace(regexp, "$1" + ui.item.value + " ");

        // Preserve original caret position to prevent it from jumping to the end
        var original_start = this.selectionStart;
        this.value += after_caret_text;
        this.selectionStart = this.selectionEnd = original_start;

        return false;
      },
      source: function(req, resp) {
        var before_caret_text = req.term.substring(0, this.element.get(0).selectionStart);

        if (before_caret_text.match(/ $/)) {
          this.close();
          return;
        }

        var term = before_caret_text.match(/\S+/g).pop();
        var regexp = new RegExp("^(?:" + prefixes + ")(.*)$");
        var match = term.match(regexp);
        if (match) {
          term = match[1];
        }
        if (term === "") {
          return;
        }

        $.ajax({
          url: "/tags.json",
          data: {
            "search[order]": "count",
            "search[name_matches]": term + "*",
            "limit": 10
          },
          method: "get",
          success: function(data) {
            resp($.map(data, function(tag) {
              return {
                label: tag.name.replace(/_/g, " "),
                value: tag.name,
                category: tag.category,
                post_count: tag.post_count
              };
            }));
          }
        });
      }
    });

    $fields_multiple.on("autocompleteselect", function() {
      Danbooru.autocompleting = true;
    });

    $fields_multiple.on("autocompleteclose", function() {
      // this is needed otherwise the var is disabled by the time the
      // keydown is triggered
      setTimeout(function() {Danbooru.autocompleting = false;}, 100);
    });

    $fields_single.autocomplete({
      minLength: 1,
      source: function(req, resp) {
        $.ajax({
          url: "/tags.json",
          data: {
            "search[order]": "count",
            "search[name_matches]": req.term + "*",
            "limit": 10
          },
          method: "get",
          success: function(data) {
            resp($.map(data, function(tag) {
              return {
                label: tag.name.replace(/_/g, " "),
                value: tag.name,
                category: tag.category,
                post_count: tag.post_count
              };
            }));
          }
        });
      }
    });

    var render_tag = function(list, tag) {
      var $link = $("<a/>").addClass("tag-type-" + tag.category).text(tag.label);
      $link.attr("href", "/posts?tags=" + encodeURIComponent(tag.value));
      $link.click(function(e) {
        e.preventDefault();
      });

      var count;
      if (tag.post_count >= 1000) {
        count = Math.floor(tag.post_count / 1000) + "k";
      } else {
        count = tag.post_count;
      }
      var $post_count = $("<span/>").addClass("post-count").css("float", "right").text(count);
      $link.append($post_count);

      return $("<li/>").data("item.autocomplete", tag).append($link).appendTo(list);
    };

    $.merge($fields_multiple, $fields_single).each(function(i, field) {
      $(field).data("uiAutocomplete")._renderItem = render_tag;
    });
  }
})();

$(document).ready(function() {
  Danbooru.Autocomplete.initialize_all();
});
