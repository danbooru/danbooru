(function() {
  Danbooru.Autocomplete = {};

  Danbooru.Autocomplete.AUTOCOMPLETE_VERSION = 1;

  Danbooru.Autocomplete.initialize_all = function() {
    if (Danbooru.meta("enable-auto-complete") === "true") {
      Danbooru.Autocomplete.enable_local_storage = this.test_local_storage();
      this.initialize_tag_autocomplete();
      this.initialize_mention_autocomplete();
      this.prune_local_storage();
    }
  }

  Danbooru.Autocomplete.test_local_storage = function() {
    try {
      $.localStorage.set("test", "test");
      $.localStorage.remove("test");
      return true;
    } catch(e) {
      return false;
    }
  }

  Danbooru.Autocomplete.prune_local_storage = function() {
    if (this.enable_local_storage) {
      var cached_autocomplete_version = $.localStorage.get("danbooru-autocomplete-version");
      if (cached_autocomplete_version !== this.AUTOCOMPLETE_VERSION || $.localStorage.keys().length > 4000) {
        $.each($.localStorage.keys(), function(i, key) {
          if (key.substr(0, 3) === "ac-") {
            $.localStorage.remove(key);
          }
        });
        $.localStorage.set("danbooru-autocomplete-version", this.AUTOCOMPLETE_VERSION);
      }
    }
  }

  Danbooru.Autocomplete.initialize_mention_autocomplete = function() {
    var $fields = $(".autocomplete-mentions textarea");
    $fields.autocomplete({
      delay: 500,
      minLength: 2,
      autoFocus: true,
      focus: function() {
        return false;
      },
      select: function(event, ui) {
        var before_caret_text = this.value.substring(0, this.selectionStart).replace(/\S+$/, ui.item.value + " ");
        var after_caret_text = this.value.substring(this.selectionStart);
        this.value = before_caret_text;

        // Preserve original caret position to prevent it from jumping to the end
        var original_start = this.selectionStart;
        this.value += after_caret_text;
        this.selectionStart = this.selectionEnd = original_start;

        return false;
      },
      source: function(req, resp) {
        var cursor = this.element.get(0).selectionStart;
        var i;
        var name = null;

        for (i=cursor; i>=1; --i) {
          if (req.term[i-1] === " ") {
            return;
          }

          if (req.term[i-1] === "@") {
            if (i == 1 || /[ \r\n]/.test(req.term[i-2])) {
              name = req.term.substring(i, cursor);
              break;
            } else {
              return;
            }
          }
        }

        if (name) {
          Danbooru.Autocomplete.user_source(name, resp, "@");
        }

        return;
      }
    });
  }

  Danbooru.Autocomplete.initialize_tag_autocomplete = function() {
    var $fields_multiple = $('[data-autocomplete="tag-query"], [data-autocomplete="tag-edit"]');
    var $fields_single = $('[data-autocomplete="tag"]');

    var prefixes = "-|~|general:|gen:|artist:|art:|copyright:|copy:|co:|character:|char:|ch:";
    var metatags = "order|-status|status|-rating|rating|-locked|locked|child|filetype|-filetype|" +
      "-user|user|-approver|approver|commenter|comm|noter|noteupdater|artcomm|-fav|fav|ordfav|" +
      "sub|-pool|pool|ordpool|favgroup";

    $fields_multiple.autocomplete({
      delay: 100,
      autoFocus: true,
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
        match = term.match(regexp);
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
        case "filetype":
        case "-filetype":
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
        case "pool":
        case "-pool":
        case "ordpool":
          Danbooru.Autocomplete.pool_source(term, resp, metatag);
          break;
        case "favgroup":
        case "-favgroup":
          Danbooru.Autocomplete.favorite_group_source(term, resp, metatag);
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
      autoFocus: true,
      source: function(req, resp) {
        Danbooru.Autocomplete.normal_source(req.term, resp);
      }
    });

    $.merge($fields_multiple, $fields_single).each(function(i, field) {
      $(field).data("uiAutocomplete")._renderItem = Danbooru.Autocomplete.render_item;
    });
  }

  Danbooru.Autocomplete.normal_source = function(term, resp) {
    var key = "ac-" + term;
    if (this.enable_local_storage) {
      var cached = $.localStorage.get(key);
      if (cached) {
        if (Date.parse(cached.expires) < new Date().getTime()) {
          $.localStorage.remove(key);
        } else {
          resp(cached.value);
          return;
        }
      }
    }

    $.ajax({
      url: "/tags/autocomplete.json",
      data: {
        "search[name_matches]": term + "*"
      },
      method: "get",
      success: function(data) {
        var d = $.map(data, function(tag) {
          return {
            type: "tag",
            label: tag.name.replace(/_/g, " "),
            antecedent: tag.antecedent_name,
            value: tag.name,
            category: tag.category,
            post_count: tag.post_count
          };
        });

        if (Danbooru.Autocomplete.enable_local_storage) {
          var expiry = new Date();
          expiry.setDate(expiry.getDate() + 7);
          $.localStorage.set(key, {"value": d, "expires": expiry});
        }
        resp(d);
      }
    });
  }

  Danbooru.Autocomplete.render_item = function(list, item) {
    var $link = $("<a/>");

    if (item.antecedent) {
      var antecedent = item.antecedent.replace(/_/g, " ");
      var arrow = $("<span/>").html(" &rarr; ").addClass("autocomplete-arrow");
      var antecedent_element = $("<span/>").text(antecedent).addClass("autocomplete-antecedent");
      $link.append(antecedent_element);
      $link.append(arrow);
    }

    $link.append(document.createTextNode(item.label));
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

  Danbooru.Autocomplete.static_metatags = {
    order: [
      "id", "id_desc",
      "score", "score_asc",
      "favcount", "favcount_asc",
      "change", "change_asc",
      "comment", "comment_asc",
      "comment_bumped", "comment_bumped_asc",
      "note", "note_asc",
      "artcomm", "artcomm_asc",
      "mpixels", "mpixels_asc",
      "portrait", "landscape",
      "filesize", "filesize_asc",
      "rank",
      "random"
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
    ],
    filetype: [
      "jpg", "png", "gif", "swf", "zip", "webm", "mp4"
    ],
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
        "search[current_user_first]": "true",
        "search[name_matches]": term + "*",
        "limit": 10
      },
      method: "get",
      success: function(data) {
        var prefix;
        var display_name;

        if (metatag === "@") {
          prefix = "@";
          display_name = function(name) {return name;};
        } else {
          prefix = metatag + ":";
          display_name = function(name) {return name.replace(/_/g, " ");};
        }

        resp($.map(data, function(user) {
          return {
            type: "user",
            label: display_name(user.name),
            value: prefix + user.name,
            level: user.level_string
          };
        }));
      }
    });
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

  Danbooru.Autocomplete.favorite_group_source = function(term, resp, metatag) {
    $.ajax({
      url: "/favorite_groups.json",
      data: {
        "search[name_matches]": term,
        "limit": 10
      },
      method: "get",
      success: function(data) {
        resp($.map(data, function(favgroup) {
          return {
            label: favgroup.name.replace(/_/g, " "),
            value: metatag + ":" + favgroup.name,
            post_count: favgroup.post_count
          };
        }));
      }
    });
  }
})();

$(document).ready(function() {
  Danbooru.Autocomplete.initialize_all();
});
