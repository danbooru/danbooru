import Utility from './utility'
import Cookie from './cookie'

let Blacklist = {};

Blacklist.entries = [];

Blacklist.parse_entry = function(string) {
  var entry = {
    "tags": string,
    "require": [],
    "exclude": [],
    "optional": [],
    "disabled": false,
    "hits": 0,
    "min_score": null
  };
  Utility.regexp_split(string).forEach(function(tag) {
    if (tag.charAt(0) === '-') {
      entry.exclude.push(tag.slice(1));
    } else if (tag.charAt(0) === '~') {
      entry.optional.push(tag.slice(1));
    } else if (tag.match(/^score:<.+/)) {
      var score = tag.match(/^score:<(.+)/)[1];
      entry.min_score = parseInt(score);
    } else {
      entry.require.push(tag);
    }
  });
  return entry;
}

Blacklist.parse_entries = function() {
  var entries = (Utility.meta("blacklisted-tags") || "nozomiisthebestlovelive").replace(/(rating:[qes])\w+/ig, "$1").toLowerCase().split(/,/);
  entries = entries.filter(e => e.trim() !== "");

  entries.forEach(function(tags) {
    var entry = Blacklist.parse_entry(tags);
    Blacklist.entries.push(entry);
  });
}

Blacklist.toggle_entry = function(e) {
  var $link = $(e.target);
  var tags = $link.text();
  var match = $.grep(Blacklist.entries, function(entry, i) {
    return entry.tags === tags;
  })[0];
  if (match) {
    match.disabled = !match.disabled;
    if (match.disabled) {
      $link.addClass("blacklisted-inactive");
    } else {
      $link.removeClass("blacklisted-inactive");
    }
  }
  Blacklist.apply();
  e.preventDefault();
}

Blacklist.update_sidebar = function() {
  Blacklist.entries.forEach(function(entry) {
    if (entry.hits.length === 0) {
      return;
    }

    var item = $("<li/>");
    var link = $("<a/>");
    var count = $("<span/>");

    link.text(entry.tags);
    link.attr("href", `/posts?tags=${encodeURIComponent(entry.tags)}`);
    link.attr("title", entry.tags);
    link.on("click.danbooru", Blacklist.toggle_entry);
    let unique_hits = new Set(entry.hits).size;
    count.html(unique_hits);
    count.addClass("count");
    item.append(link);
    item.append(" ");
    item.append(count);

    $("#blacklist-list").append(item);
  });

  $("#blacklist-box").show();
}

Blacklist.disable_all = function() {
  Blacklist.entries.forEach(function(entry) {
    entry.disabled = true;
  });
  // There is no need to process the blacklist when disabling
  Blacklist.posts().removeClass("blacklisted-active");
  $("#disable-all-blacklists").hide();
  $("#re-enable-all-blacklists").show();
  $("#blacklist-list a").addClass("blacklisted-inactive");
}

Blacklist.enable_all = function() {
  Blacklist.entries.forEach(function(entry) {
    entry.disabled = false;
  });
  Blacklist.apply();
  $("#disable-all-blacklists").show();
  $("#re-enable-all-blacklists").hide();
  $("#blacklist-list a").removeClass("blacklisted-inactive");
}

Blacklist.initialize_disable_all_blacklists = function() {
  if (Cookie.get("dab") === "1") {
    Blacklist.disable_all();
  } else {
    // The blacklist has already been processed by this point
    $("#disable-all-blacklists").show()
  }

  $("#disable-all-blacklists").on("click.danbooru", function(e) {
    Cookie.put("dab", "1");
    Blacklist.disable_all();
    e.preventDefault();
  });

  $("#re-enable-all-blacklists").on("click.danbooru", function(e) {
    Cookie.put("dab", "0");
    Blacklist.enable_all();
    e.preventDefault();
  });
}

Blacklist.apply = function() {
  Blacklist.entries.forEach(function(entry) {
    entry.hits = [];
  });

  var count = 0

  Blacklist.posts().each(function(i, post) {
    count += Blacklist.apply_post(post);
  });

  return count;
}

Blacklist.apply_post = function(post) {
  var post_count = 0;
  Blacklist.entries.forEach(function(entry) {
    if (Blacklist.post_match(post, entry)) {
      let post_id = $(post).data('id');
      entry.hits.push(post_id);
      post_count += 1;
    }
  });
  if (post_count > 0) {
    Blacklist.post_hide(post);
  } else {
    Blacklist.post_unhide(post);
  }
  return post_count;
};

Blacklist.posts = function() {
  return $(".post-preview, .image-container, #c-comments .post, .mod-queue-preview.post-preview");
}

Blacklist.post_match = function(post, entry) {
  if (entry.disabled) {
    return false;
  }

  var $post = $(post);
  var score = parseInt($post.attr("data-score"));
  var score_test = entry.min_score === null || score < entry.min_score;

  var tags = Utility.regexp_split($post.attr("data-tags"));
  tags.push(...Utility.regexp_split($post.attr("data-pools")));
  tags.push("rating:" + $post.data("rating"));
  tags.push("uploaderid:" + $post.attr("data-uploader-id"));
  Utility.regexp_split($post.data("flags")).forEach(function(v) {
    tags.push("status:" + v);
  });

  return (Utility.is_subset(tags, entry.require) && score_test)
    && (!entry.optional.length || Utility.intersect(tags, entry.optional).length)
    && !Utility.intersect(tags, entry.exclude).length;
}

Blacklist.post_hide = function(post) {
  var $post = $(post);
  $post.addClass("blacklisted blacklisted-active");

  var $video = $post.find("video").get(0);
  if ($video) {
    $video.pause();
    $video.currentTime = 0;
  }
}

Blacklist.post_unhide = function(post) {
  var $post = $(post);
  $post.addClass("blacklisted").removeClass("blacklisted-active");

  var $video = $post.find("video").get(0);
  if ($video) {
    $video.play();
  }
}

Blacklist.initialize_all = function() {
  Blacklist.parse_entries();

  if (Blacklist.apply() > 0) {
    Blacklist.update_sidebar();
    Blacklist.initialize_disable_all_blacklists();
  }
}

$(document).ready(function() {
  if ($("#blacklist-box").length === 0) {
    return;
  }

  Blacklist.initialize_all();
});

export default Blacklist
