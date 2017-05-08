(function() {
  Danbooru.Blacklist = {};

  Danbooru.Blacklist.entries = [];

  Danbooru.Blacklist.parse_entry = function(string) {
    var entry = {
      "tags": string,
      "require": [],
      "exclude": [],
      "disabled": false,
      "hits": 0,
      "min_score": null
    };
    var matches = string.match(/\S+/g) || [];
    $.each(matches, function(i, tag) {
      if (tag.charAt(0) === '-') {
        entry.exclude.push(tag.slice(1));
      } else if (tag.match(/^score:<.+/)) {
        var score = tag.match(/^score:<(.+)/)[1];
        entry.min_score = parseInt(score);
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
        Danbooru.Blacklist.post_hide(e.target);
      } else {
        Danbooru.Blacklist.post_unhide(e.target);
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
      var hash = entry.tags.hash();

      link.text(entry.tags);
      link.click(Danbooru.Blacklist.toggle_entry);
      count.html(entry.hits);
      count.addClass("count");
      item.append(link);
      item.append(" ");
      item.append(count);

      $("#blacklist-list").append(item);
    });

    $("#blacklist-box").show();
  }

  Danbooru.Blacklist.initialize_disable_all_blacklists = function() {
    if (Danbooru.Cookie.get("dab") === "1") {
      $("#re-enable-all-blacklists").show();
      $("#blacklist-list a:not(.blacklisted-active)").click();
      Danbooru.Blacklist.apply();
    } else {
      $("#disable-all-blacklists").show()
    }

    $("#disable-all-blacklists").click(function(e) {
      $("#disable-all-blacklists").hide();
      $("#re-enable-all-blacklists").show();
      Danbooru.Cookie.put("dab", "1");
      $("#blacklist-list a:not(.blacklisted-active)").click();
      e.preventDefault();
    });

    $("#re-enable-all-blacklists").click(function(e) {
      $("#disable-all-blacklists").show();
      $("#re-enable-all-blacklists").hide();
      Danbooru.Cookie.put("dab", "0");
      $("#blacklist-list a.blacklisted-active").click();
      e.preventDefault();
    });
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
        Danbooru.Blacklist.post_unhide(post);
      }
    });

    return count;
  }

  Danbooru.Blacklist.posts = function() {
    return $(".post-preview, #image-container, #c-comments .post");
  }

  Danbooru.Blacklist.post_match = function(post, entry) {
    if (entry.disabled) {
      return false;
    }

    var $post = $(post);
    var score = parseInt($post.attr("data-score"));

    if (entry.min_score !== null && score < entry.min_score) {
      return true;
    }

    var tags = String($post.attr("data-tags")).match(/\S+/g) || [];
    tags = tags.concat(String($post.attr("data-pools")).match(/\S+/g) || []);
    tags.push("rating:" + $post.data("rating"));
    tags.push("user:" + $post.attr("data-uploader").toLowerCase());
    $.each(String($post.data("flags")).match(/\S+/g) || [], function(i, v) {
      tags.push("status:" + v);
    });
    return (entry.require.length > 0 || entry.exclude.length > 0) && Danbooru.is_subset(tags, entry.require) && !Danbooru.intersect(tags, entry.exclude).length;
  }

  Danbooru.Blacklist.post_hide = function(post) {
    var $post = $(post);
    $post.addClass("blacklisted").addClass("blacklisted-active");

    var $video = $post.find("video").get(0);
    if ($video) {
      $video.pause();
      $video.currentTime = 0;
    }
  }

  Danbooru.Blacklist.post_unhide = function(post) {
    var $post = $(post);
    $post.addClass("blacklisted").removeClass("blacklisted-active");

    var $video = $post.find("video").get(0);
    if ($video) {
      $video.play();
    }
  }

  Danbooru.Blacklist.initialize_all = function() {
    Danbooru.Blacklist.parse_entries();

    if (Danbooru.Blacklist.apply() > 0) {
      Danbooru.Blacklist.update_sidebar();
      Danbooru.Blacklist.initialize_disable_all_blacklists();
    } else {
      $("#blacklist-box").hide();
    }
  }
})();

$(document).ready(function() {
  if ($("#c-moderator-post-queues").length) {
    return;
  }

  Danbooru.Blacklist.initialize_all();
});
