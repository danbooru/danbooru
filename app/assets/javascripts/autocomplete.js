(function() {
  Danbooru.Autocomplete = {};

  Danbooru.Autocomplete.initialize_all = function() {
    if (Danbooru.meta("enable-auto-complete") === "true") {
      this.initialize_tag_autocomplete();
    }
  }

  Danbooru.Autocomplete.initialize_tag_autocomplete = function() {
    var $fields_multiple = $(
      "#tags,#post_tag_string,#upload_tag_string,#tag-script-field,#c-moderator-post-queues #query," +
      "#user_blacklisted_tags,#user_favorite_tags,#tag_subscription_tag_query"
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
    var metatags = "order|-status|status|-rating|rating|-locked|locked|child|" + 
      "-user|user|-approver|approver|commenter|comm|noter|noteupdater|artcomm|-fav|fav|ordfav|" +
      "sub|-pool|pool|ordpool";

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
        var regexp = new RegExp("^(?:" + prefixes + ")(.*)$", "i");
        var match = term.match(regexp);
        if (match) {
          term = match[1];
        }
        if (term === "") {
          return;
        }

        regexp = new RegExp("^(" + metatags + "):(.*)$", "i");
        var match = term.match(regexp);
        var metatag;
        if (match) {
          metatag = match[1].toLowerCase();
          term = match[2];
        }

        switch(metatag) {
        case "order":
        case "status":
        case "-status":
        case "rating":
        case "-rating":
        case "locked":
        case "-locked":
        case "child":
          Danbooru.Autocomplete.static_metatag_source(term, resp, metatag);
          return;
        }

        if (term === "") {
          return;
        }

        switch(metatag) {
        case "user":
        case "-user":
        case "approver":
        case "-approver":
        case "commenter":
        case "comm":
        case "noter":
        case "noteupdater":
        case "artcomm":
        case "fav":
        case "-fav":
        case "ordfav":
          Danbooru.Autocomplete.user_source(term, resp, metatag);
          break;
        case "sub":
          Danbooru.Autocomplete.subscription_source(term, resp);
          break;
        case "pool":
        case "-pool":
        case "ordpool":
          Danbooru.Autocomplete.pool_source(term, resp, metatag);
          break;
        default:
          Danbooru.Autocomplete.normal_source(term, resp);
          break;
        }
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
                type: "tag",
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

    $.merge($fields_multiple, $fields_single).each(function(i, field) {
      $(field).data("uiAutocomplete")._renderItem = Danbooru.Autocomplete.render_item;
    });
  }

  Danbooru.Autocomplete.render_item = function(list, item) {
    var $link = $("<a/>").text(item.label);
    $link.attr("href", "/posts?tags=" + encodeURIComponent(item.value));
    $link.click(function(e) {
      e.preventDefault();
    });

    if (item.post_count !== undefined) {
      var count;
      if (item.post_count >= 1000) {
        count = Math.floor(item.post_count / 1000) + "k";
      } else {
        count = item.post_count;
      }
      var $post_count = $("<span/>").addClass("post-count").css("float", "right").text(count);
      $link.append($post_count);
    }

    if (item.type === "tag") {
      $link.addClass("tag-type-" + item.category);
    } else if (item.type === "user") {
      var level_class = "user-" + item.level.toLowerCase();
      $link.addClass(level_class);
      if (Danbooru.meta("style-usernames") === "true") {
        $link.addClass("with-style");
      }
    } else if (item.type === "pool") {
      $link.addClass("pool-category-" + item.category);
    }

    return $("<li/>").data("item.autocomplete", item).append($link).appendTo(list);
  };

  Danbooru.Autocomplete.normal_source = function(term, resp) {
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
            type: "tag",
            label: tag.name.replace(/_/g, " "),
            value: tag.name,
            category: tag.category,
            post_count: tag.post_count
          };
        }));
      }
    });
  }

  Danbooru.Autocomplete.static_metatags = {
    order: [
      "id", "id_desc",
      "score", "score_asc",
      "favcount", "favcount_asc",
      "change", "change_asc",
      "comment", "comment_asc",
      "note", "note_asc",
      "artcomm", "artcomm_asc",
      "mpixels", "mpixels_asc",
      "portrait", "landscape",
      "filesize", "filesize_asc",
      "rank"
    ],
    status: [
      "any", "deleted", "active", "pending", "flagged", "banned"
    ],
    rating: [
      "safe", "questionable", "explicit"
    ],
    locked: [
      "rating", "note", "status"
    ],
    child: [
      "any", "none"
    ]
  }

  Danbooru.Autocomplete.static_metatag_source = function(term, resp, metatag) {
    var sub_metatags = this.static_metatags[metatag];

    var regexp = new RegExp("^" + $.ui.autocomplete.escapeRegex(term), "i");
    var matches = $.grep(sub_metatags, function (sub_metatag) {
      return regexp.test(sub_metatag);
    });

    resp($.map(matches, function(sub_metatag) {
      return metatag + ":" + sub_metatag;
    }));
  }

  Danbooru.Autocomplete.user_source = function(term, resp, metatag) {
    $.ajax({
      url: "/users.json",
      data: {
        "search[order]": "post_upload_count",
        "search[name_matches]": term + "*",
        "limit": 10,
      },
      method: "get",
      success: function(data) {
        resp($.map(data, function(user) {
          return {
            type: "user",
            label: user.name.replace(/_/g, " "),
            value: metatag + ":" + user.name,
            level: user.level_string
          };
        }));
      }
    });
  }

  Danbooru.Autocomplete.subscription_source = function(term, resp) {
    var match = term.match(/^(.+?):(.*)$/);
    if (match) {
      var user_name = match[1];
      var subscription_name = match[2];

      $.ajax({
        url: "/tag_subscriptions.json",
        data: {
          "search[creator_name]": user_name,
          "search[name_matches]": subscription_name + "*",
          "limit": 10
        },
        method: "get",
        success: function(data) {
          resp($.map(data, function(subscription) {
            return {
              label: subscription.name.replace(/_/g, " "),
              value: "sub:" + user_name + ":" + subscription.name
            };
          }));
        }
      });
    } else {
      Danbooru.Autocomplete.user_source(term, resp, "sub");
    }
  }

  Danbooru.Autocomplete.pool_source = function(term, resp, metatag) {
    $.ajax({
      url: "/pools.json",
      data: {
        "search[order]": "post_count",
        "search[name_matches]": term,
        "limit": 10
      },
      method: "get",
      success: function(data) {
        resp($.map(data, function(pool) {
          return {
            type: "pool",
            label: pool.name.replace(/_/g, " "),
            value: metatag + ":" + pool.name,
            post_count: pool.post_count,
            category: pool.category
          };
        }));
      }
    });
  }
})();

$(document).ready(function() {
  Danbooru.Autocomplete.initialize_all();
});
