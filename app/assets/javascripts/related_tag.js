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
    if ($("#c-uploads").length) {
      if ($("#upload_source").val().match(/pixiv\.net/)){
        $("#find-artist-button").trigger("click");
      }
    }
    $("#find-artist-button").click(Danbooru.RelatedTag.find_artist);
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

    if ((a > 0) && (a < (n - 1)) && (string[a] !== " ") && (string[a - 1] === " ")) {
      // 4 is the only case where we need to scan forward. in all other cases we
      // can drag a backwards, and then drag b forwards.
      
      while ((b < n) && (string[b] !== " ")) {
        b++;
      }
    } else {
      while ((a > 0) && ((string[a] === " ") || (string[a] === undefined))) {
        a--;
        b--;
      }
      
      while ((a > 0) && (string[a - 1] !== " ")) {
        a--;
        b--;
      }
      
      while ((b < (n - 1)) && (string[b] !== " ")) {
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
  
  Danbooru.RelatedTag.build_html = function(query, related_tags) {
    if (query === null || query === "") {
      return "";
    }

    var current = $("#upload_tag_string,#post_tag_string").val().match(/\S+/g) || [];
    var $div = $("<div/>").addClass("tag-column");
    var $ul = $("<ul/>");
    $ul.append(
      $("<li/>").append(
        $("<em/>").html(
          query.replace(/_/g, " ")
        )
      )
    );
    
    $.each(related_tags, function(i, tag) {
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
    });
    
    $div.append($ul);
    return $div;
  }
  
  Danbooru.RelatedTag.toggle_tag = function(e) {
    var $field = $("#upload_tag_string,#post_tag_string");
    var tags = $field.val().match(/\S+/g) || [];
    var tag = $(e.target).html().replace(/ /g, "_").replace(/&gt;/g, ">").replace(/&lt;/g, "<").replace(/&amp;/g, "&");

    if ($.inArray(tag, tags) > -1) {
      $field.val(Danbooru.without(tags, tag).join(" ") + " ");
    } else {
      $field.val(tags.concat([tag]).join(" ") + " ");
    }

    $field[0].selectionStart = $field.val().length;
    Danbooru.RelatedTag.build_all();
    e.preventDefault();
  }
  
  Danbooru.RelatedTag.find_artist = function(e) {
    $("#artist-tags").html("<em>Loading...</em>");
    Danbooru.RelatedTag.recent_search = null;
    var url = $("#upload_source,#post_source");
    $.get("/artists.json", {"search[name]": url.val()}).success(Danbooru.RelatedTag.process_artist);
    e.preventDefault();
  }
  
  Danbooru.RelatedTag.process_artist = function(data) {
    $("#artist-tags-container").show();
    var $dest = $("#artist-tags");
    $dest.empty();
    
    if (data.length === 0) {
      $dest.html("No artists found");
      return;
    } else if (data.length > 2) {
      $dest.html("Too many matching artists found");
      return;
    }
    
    $.each(data, function(i, json) {
      if (!json.other_names) {
        json.other_names = "";
      }
      var $div = $("<div/>").addClass("artist");
      var $ul = $("<ul/>");
      $ul.append(
        $("<li/>").append("Artist: ").append(
          $("<a/>").attr("href", "/artists/" + json.id).html(json.name).click(Danbooru.RelatedTag.toggle_tag)
        )
      );
      if (json.other_names.length > 0) {
        $ul.append($("<li/>").html("Other names: " + json.other_names));
      }
      $.each(json.urls, function(i, v) {
        $ul.append($("<li/>").html("URL: " + v.url));
      });
      $div.append($ul);
      $dest.append($div);
    });
  }
})();

$(function() {
  Danbooru.RelatedTag.initialize_all();
});
