(function() {
  Danbooru.RelatedTag = {};

  Danbooru.RelatedTag.initialize_all = function() {
    if ($("#c-posts").length || $("#c-uploads").length) {
      this.initialize_buttons();
      $("#related-tags-container").hide();
      $("#artist-tags-container").hide();
    }
  }

  Danbooru.RelatedTag.initialize_buttons = function() {
    this.common_bind("#related-tags-button", "");
    this.common_bind("#related-artists-button", "artist");
    this.common_bind("#related-characters-button", "character");
    this.common_bind("#related-copyrights-button", "copyright");
    $("#find-artist-button").click(Danbooru.RelatedTag.find_artist);
  }
  
  Danbooru.RelatedTag.tags_include = function(name) {
    var current = $("#upload_tag_string,#post_tag_string").val().match(/\S+/g) || [];
    if ($.inArray(name, current) > -1) {
      return true;
    } else {
      return false;
    }
  }

  Danbooru.RelatedTag.common_bind = function(button_name, category) {
    $(button_name).click(function(e) {
      $("#related-tags").html("<em>Loading...</em>");
      $("#related-tags-container").show();
      $.get("/related_tag.json", {
        "query": Danbooru.RelatedTag.current_tag(),
        "category": category
      }).success(Danbooru.RelatedTag.process_response);
      $("#artist-tags-container").hide();
      e.preventDefault();
    });
  }

  Danbooru.RelatedTag.current_tag = function() {
    // 1. abc def |  -> def
    // 2. abc def|   -> def
    // 3. abc de|f   -> def
    // 4. abc |def   -> def
    // 5. abc| def   -> abc
    // 6. ab|c def   -> abc
    // 7. |abc def   -> abc
    // 8. | abc def  -> abc   -- not supported by this code but a pretty rare case

    var $field = $("#upload_tag_string,#post_tag_string");
    var string = $field.val().trim();
    var n = string.length;
    var a = $field.get(0).selectionStart;
    var b = $field.get(0).selectionStart;

    if ((a > 0) && (a < (n - 1)) && (!/\s/.test(string[a])) && (/\s/.test(string[a - 1]))) {
      // 4 is the only case where we need to scan forward. in all other cases we
      // can drag a backwards, and then drag b forwards.

      while ((b < n) && (!/\s/.test(string[b]))) {
        b++;
      }
    } else {
      while ((a > 0) && ((/\s/.test(string[a])) || (string[a] === undefined))) {
        a--;
        b--;
      }

      while ((a > 0) && (!/\s/.test(string[a - 1]))) {
        a--;
        b--;
      }

      while ((b < (n - 1)) && (!/\s/.test(string[b]))) {
        b++;
      }
    }

    b++;
		return string.slice(a, b);
  }

  Danbooru.RelatedTag.process_response = function(data) {
    Danbooru.RelatedTag.recent_search = data;
    Danbooru.RelatedTag.build_all();
  }

  Danbooru.RelatedTag.build_all = function() {
    if (Danbooru.RelatedTag.recent_search === null || Danbooru.RelatedTag.recent_search === undefined) {
      return;
    }

    $("#related-tags").show();

    var query = Danbooru.RelatedTag.recent_search.query;
    var related_tags = Danbooru.RelatedTag.recent_search.tags;
    var wiki_page_tags = Danbooru.RelatedTag.recent_search.wiki_page_tags;
    var $dest = $("#related-tags");
    $dest.empty();

    if (Danbooru.Cookie.get("recent_tags")) {
      $dest.append(Danbooru.RelatedTag.build_html("recent", Danbooru.RelatedTag.recent_tags()));
    }
    if (Danbooru.RelatedTag.favorite_tags().length) {
      $dest.append(Danbooru.RelatedTag.build_html("favorite", Danbooru.RelatedTag.favorite_tags()));
    }
    $dest.append(Danbooru.RelatedTag.build_html(query, related_tags));
    if (wiki_page_tags.length) {
      $dest.append(Danbooru.RelatedTag.build_html("wiki:" + query, wiki_page_tags));
    }
    if (Danbooru.RelatedTag.recent_artists) {
      var tags = [];
      if (Danbooru.RelatedTag.recent_artists.length !== 1) {
        tags.push([" none", 0]);
      } else {
        tags.push([Danbooru.RelatedTag.recent_artists[0].name, 1]);
        $.each(Danbooru.RelatedTag.recent_artists[0].urls, function(i, url) {
          tags.push([" " + url.url, 0]);
        });
      }
     $dest.append(Danbooru.RelatedTag.build_html("artist", tags, true));
    }
  }

  Danbooru.RelatedTag.favorite_tags = function() {
    var string = Danbooru.meta("favorite-tags");
    if (string) {
      return $.map(string.match(/\S+/g), function(x, i) {
        return [[x, 0]];
      });
    } else {
      return [];
    }
  }

  Danbooru.RelatedTag.recent_tags = function() {
    var string = Danbooru.Cookie.get("recent_tags");
    if (string && string.length) {
      return $.map(string.match(/\S+/g), function(x, i) {
        return [[x, 0]];
      });
    } else {
      return [];
    }
  }

  Danbooru.RelatedTag.build_html = function(query, related_tags, is_wide_column) {
    if (query === null || query === "") {
      return "";
    }

    var current = $("#upload_tag_string,#post_tag_string").val().match(/\S+/g) || [];
    var $div = $("<div/>");
    $div.addClass("tag-column")
    if (is_wide_column) {
      $div.addClass("wide-column");
    }
    var $ul = $("<ul/>");
    $ul.append(
      $("<li/>").append(
        $("<em/>").html(
          query.replace(/_/g, " ")
        )
      )
    );

    $.each(related_tags, function(i, tag) {
      if (tag[0][0] !== " ") {
        var $link = $("<a/>");
        $link.html(tag[0].replace(/_/g, " "));
        $link.addClass("tag-type-" + tag[1]);
        $link.attr("href", "/posts?tags=" + encodeURIComponent(tag[0]));
        $link.click(Danbooru.RelatedTag.toggle_tag);
        if ($.inArray(tag[0], current) > -1) {
          $link.addClass("selected");
        }
        $ul.append(
          $("<li/>").append($link)
        );
      } else {
        $ul.append($("<li/>").html(tag[0]));
      }
    });

    $div.append($ul);
    return $div;
  }

  Danbooru.RelatedTag.toggle_tag = function(e) {
    var $field = $("#upload_tag_string,#post_tag_string");
    var tags = $field.val().match(/\S+/g) || [];
    var tag = $(e.target).html().replace(/ /g, "_").replace(/&gt;/g, ">").replace(/&lt;/g, "<").replace(/&amp;/g, "&");

    if ($.inArray(tag, tags) > -1) {
      var escaped_tag = Danbooru.regexp_escape(tag);
      $field.val($field.val().replace(new RegExp("(^|\\s)" + escaped_tag + "($|\\s)", "gi"), "$1$2"));
    } else {
      $field.val($field.val() + " " + tag);
    }
    $field.val($field.val().trim().replace(/ +/g, " ") + " ");

    $field[0].selectionStart = $field.val().length;
    Danbooru.RelatedTag.build_all();
    if (Danbooru.RelatedTag.recent_artist && $("#artist-tags-container").css("display") === "block") {
      Danbooru.RelatedTag.process_artist(Danbooru.RelatedTag.recent_artist);
    }
    e.preventDefault();
  }

  Danbooru.RelatedTag.find_artist = function(e) {
    $("#artist-tags").html("<em>Loading...</em>");
    var url = $("#upload_source,#post_source");
    $.get("/artists.json", {"limit": 2, "search[name]": url.val()}).success(Danbooru.RelatedTag.process_artist);
    e.preventDefault();
  }

  Danbooru.RelatedTag.process_artist = function(data) {
    Danbooru.RelatedTag.recent_artists = data;
    Danbooru.RelatedTag.build_all();
  }
})();

$(function() {
  Danbooru.RelatedTag.initialize_all();
});
