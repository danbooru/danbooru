(function() {
  Danbooru.Blacklist = {};

  Danbooru.Blacklist.entries = [];

  Danbooru.Blacklist.parse_entry = function(string) {
    var entry = {
      "tags": string,
      "require": [],
      "exclude": [],
      "disabled": false,
      "hits": 0
    };
    var matches = string.match(/\S+/g) || [];
    $.each(matches, function(i, tag) {
      if (tag.charAt(0) === '-') {
        entry.exclude.push(tag.slice(1));
      } else {
        entry.require.push(tag);
      }
    });
    return entry;
  }

  Danbooru.Blacklist.parse_entries = function() {
    var entries = (Danbooru.meta("blacklisted-tags") || "nozomiisthebestlovelive").replace(/(rating:[qes])\w+/ig, "$1").toLowerCase().split(/,/);

    $.each(entries, function(i, tags) {
      var entry = Danbooru.Blacklist.parse_entry(tags);
      Danbooru.Blacklist.entries.push(entry);
    });
  }

  Danbooru.Blacklist.toggle_entry = function(e) {
    var tags = $(e.target).text();
    var match = $.grep(Danbooru.Blacklist.entries, function(entry, i) {
      return entry.tags === tags;
    })[0];
    if (match) {
      match.disabled = !match.disabled;
      if (match.disabled) {
        $(e.target).addClass("blacklisted-active");
      } else {
        $(e.target).removeClass("blacklisted-active");
      }
    }
    Danbooru.Blacklist.apply();
  }

  Danbooru.Blacklist.update_sidebar = function() {
    $.each(this.entries, function(i, entry) {
      if (entry.hits === 0) {
        return;
      }

      var item = $("<li/>");
      var link = $("<a/>");
      var count = $("<span/>");

      link.text(entry.tags);
      link.click(Danbooru.Blacklist.toggle_entry);
      count.html(entry.hits);
      item.append(link);
      item.append(" ");
      item.append(count);

      $("#blacklist-list").append(item);
    });

    $("#blacklist-box").show();
  }

  Danbooru.Blacklist.apply = function() {
    $.each(this.entries, function(i, entry) {
      entry.hits = 0;
    });

    var count = 0

    $.each(this.posts(), function(i, post) {
      var post_count = 0;
      $.each(Danbooru.Blacklist.entries, function(i, entry) {
        if (Danbooru.Blacklist.post_match(post, entry)) {
          entry.hits += 1;
          count += 1;
          post_count += 1;
        }
      });
      if (post_count > 0) {
        Danbooru.Blacklist.post_hide(post);
      } else {
        $(post).removeClass("blacklisted-active");
      }
    });

    return count;
  }

  Danbooru.Blacklist.posts = function() {
    return $(".post-preview, #image-container")
  }

  Danbooru.Blacklist.post_match = function(post, entry) {
    if (entry.disabled) {
      return false;
    }
    
    var $post = $(post);
    var tags = String($post.attr("data-tags")).match(/\S+/g) || [];
    tags.push("rating:" + $post.data("rating"));
    tags.push("user:" + $post.attr("data-uploader").toLowerCase().replace(/ /g, "_"));
    $.each(String($post.data("flags")).match(/\S+/g) || [], function(i, v) {
      tags.push("status:" + v);
    });
    return (entry.require.length > 0 || entry.exclude.length > 0) && Danbooru.is_subset(tags, entry.require) && !Danbooru.intersect(tags, entry.exclude).length;
  }

  Danbooru.Blacklist.post_hide = function(post) {
    var $post = $(post);
    $post.addClass("blacklisted").addClass("blacklisted-active");
  }

  Danbooru.Blacklist.initialize_all = function() {
    Danbooru.Blacklist.parse_entries();

    if (Danbooru.Blacklist.apply() > 0) {
      Danbooru.Blacklist.update_sidebar();
    } else {
      $("#blacklist-box").hide();
    }
  }
})();

$(document).ready(function() {
  Danbooru.Blacklist.initialize_all();
});
