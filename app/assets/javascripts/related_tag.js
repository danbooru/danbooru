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
    var query = data.query;
    var related_tags = data.tags;
    var wiki_page_tags = data.wiki_page_tags;
    var $dest = $("#related-tags");
    
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
})();

$(function() {
  Danbooru.RelatedTag.initialize_all();
});
