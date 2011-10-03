(function() {
  Danbooru.RelatedTag = {};
  
  Danbooru.RelatedTag.initialize_all = function() {
    this.initialize_buttons();
  }
  
  Danbooru.RelatedTag.initialize_buttons = function() {
    this.common_bind("#related-tags-button", "");
    this.common_bind("#related-artists-button", "artist");
    this.common_bind("#related-characters-button", "character");
    this.common_bind("#related-copyrights-button", "copyright");
    $("find-artist-button").click(Danbooru.RelatedTag.find_artist);
  }
  
  Danbooru.RelatedTag.common_bind = function(button_name, category) {
    $(button_name).click(function(e) {
      $.get("/related_tag.json", {
        "query": Danbooru.RelatedTag.current_tag(),
        "category": category
      }).success(Danbooru.RelatedTag.process_response);
      e.preventDefault();
    });
  }
  
  Danbooru.RelatedTag.current_tag = function() {
    var $field = $("#upload_tag_string,#post_tag_string");
    var string = $field.val();
    var text_length = string.length;
    var a = $field[0].selectionStart;
    var b = $field[0].selectionStart;
    
  	while ((a > 0) && string[a] != " ") {
			a -= 1;
		}

		if (string[a] == " ") {
			a += 1;
		}

		while ((b < text_length) && string[b] != " ") {
			b += 1;
		}

		return string.slice(a, b);
  }
  
  Danbooru.RelatedTag.process_response = function(data) {
    Danbooru.RelatedTag.recent_search = data;
    Danbooru.RelatedTag.build_all();
  }
  
  Danbooru.RelatedTag.build_all = function() {
    var query = Danbooru.RelatedTag.recent_search.query;
    var related_tags = Danbooru.RelatedTag.recent_search.tags;
    var wiki_page_tags = Danbooru.RelatedTag.recent_search.wiki_page_tags;
    var $dest = $("#related-tags");
    $dest.empty();
    
    $dest.append(Danbooru.RelatedTag.build_html(query, related_tags));
    if (wiki_page_tags.length > 0) {
      $dest.append(Danbooru.RelatedTag.build_html("wiki:" + query), wiki_page_tags);
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
      if ($.inArray(tag, current)) {
        $link.addClass("active");
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
    var tag = $(e.target).html().replace(/ /g, "_");

    if ($.inArray(tag, tags)) {
      $field.val(Danbooru.without(tags, tag).join(" ") + " ");
    } else {
      $field.val(tags.concat([tag]).join(" ") + " ");
    }

    $field[0].selectionStart = $field.val().length;
    Danbooru.RelatedTag.build_all();
    e.preventDefault();
  }
  
  Danbooru.RelatedTag.find_artist = function(e) {
    var url = $("#upload_source,#post_source");
    $.get("/artists.json", {"search[url_match]": url.val()}).success(Danbooru.RelatedTag.process_artist);
    e.preventDefault();
  }
  
  Danbooru.RelatedTag.process_artist = function(data) {
    var $dest = $("#related-tags");
    $dest.empty();
    
    if (data.size() === 0) {
      $dest.html("No artists found");
      return;
    }
    
    $.each(data, function(i, json) {
      var id = json.id;
      var name = json.name;
      var other_names = json.other_names;
      var urls
    });
  }
})();

$(function() {
  Danbooru.RelatedTag.initialize_all();
});
