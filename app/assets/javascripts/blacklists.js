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

  Danbooru.Blacklist.show_entry = function(e) {
    $(".blacklisted").addClass("blacklisted-active");
    
    Danbooru.Blacklist.posts().each(function(i, post) {
      var $post = $(post);
      var tag = $(e.target).html();
      var entry = Danbooru.Blacklist.parse_entry(tag);

      if (Danbooru.Blacklist.post_match($post, entry)) {
        $post.removeClass("blacklisted-active");
      }
    });
  }

  Danbooru.Blacklist.toggle_all = function(e) {
    if ($(".blacklisted-active").length) {
      $(".blacklisted").removeClass("blacklisted-active");
    } else {
      $(".blacklisted").addClass("blacklisted-active");
    }
  }

  Danbooru.Blacklist.update_sidebar = function() {
    if (this.entries.length > 0) {
      this.entries.unshift({"tags": "~all~", "hits": -1});
    }

    $.each(this.entries, function(i, entry) {
      if (entry.hits === 0) {
        return;
      }

      var item = $("<li/>");
      var link = $("<a/>");
      var count = $("<span/>");

      if (entry.tags === "~all~") {
        link.html("All");
        link.click(Danbooru.Blacklist.toggle_all);
        item.append(link);
        item.append(" ");
      } else {
        link.html(entry.tags);
        link.click(Danbooru.Blacklist.show_entry);
        count.html(entry.hits);
        item.append(link);
        item.append(" ");
        item.append(count);
      }

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
      $.each(Danbooru.Blacklist.entries, function(i, entry) {
        if (Danbooru.Blacklist.post_match(post, entry)) {
          Danbooru.Blacklist.post_hide(post);
          entry.hits += 1;
          count += 1;
        }
      });
    });

    return count;
  }

  Danbooru.Blacklist.posts = function() {
    return $(".post-preview");
  }

  Danbooru.Blacklist.post_match = function(post, entry) {
    var $post = $(post);
    var tags = String($post.data("tags")).match(/\S+/g) || [];
    tags.push("rating:" + $post.data("rating"));
    tags.push("user:" + $post.data("user"));
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
