(function() {
  Danbooru.Blacklist = {};
  
  Danbooru.Blacklist.blacklists = [];
  
  Danbooru.Blacklist.parse_entries = function() {
    var raw = $('<textarea/>').html(Danbooru.meta("blacklisted-tags") || "[]").val();
    var entries = ($.parseJSON(raw)).replace(/(rating:[qes])\w+/, "$1").split(/,/);
    $.each(entries, function(i, tags) {
      var blacklist = {
        "tags": tags, 
        "require": [], 
        "exclude": [], 
        "disabled": false, 
        "hits": 0
      };
      var matches = tags.match(/\S+/g) || [];
      $.each(matches, function(i, tag) {
        if (tag.charAt(0) === '-') {
          blacklist.exclude.push(tag.slice(1));
        } else {
          blacklist.require.push(tag);
        }
      })
      Danbooru.Blacklist.blacklists.push(blacklist);
    });
  }
  
  Danbooru.Blacklist.toggle = function(e) {
    $(".blacklisted").each(function(i, element) {
      var $element = $(element);
      if ($element.hasClass("blacklisted-active")) {
        $element.removeClass("blacklisted-active");
      } else {
        $element.addClass("blacklisted-active");
      }
    });
  }
  
  Danbooru.Blacklist.update_sidebar = function() {
    $.each(this.blacklists, function(i, blacklist) {
      if (blacklist.hits === 0) {
        return;
      }
      
      var item = $("<li/>");
      var link = $("<a/>");
      var count = $("<span/>");
      link.html(blacklist.tags);
      link.click(Danbooru.Blacklist.toggle);
      count.html(blacklist.hits);
      item.append(link);
      item.append(" ");
      item.append(count);
      $("#blacklist-list").append(item);
    });
    
    $("#blacklist-box").show();
  }
  
  Danbooru.Blacklist.apply = function() {
    $.each(this.blacklists, function(i, blacklist) {
      blacklist.hits = 0;
    });

    var count = 0
    
    $.each(this.posts(), function(i, post) {
      $.each(Danbooru.Blacklist.blacklists, function(i, blacklist) {
        if (Danbooru.Blacklist.post_match(post, blacklist)) {
          Danbooru.Blacklist.post_hide(post);
          blacklist.hits += 1;
          count += 1;
        }
      });
    });
    
    return count;
  }
  
  Danbooru.Blacklist.posts = function() {
    return $(".post-preview");
  }
  
  Danbooru.Blacklist.post_match = function(post, blacklist) {
    var $post = $(post);
    var tags = String($post.data("tags")).match(/\S+/g) || [];
    tags.push("rating:" + $post.data("rating"));
    tags.push("uploader:" + $post.data("uploader"));
    
    if (blacklist.require.length > 0 || blacklist.exclude.length > 0) {
      if (blacklist.require.length === 0 || Danbooru.is_subset(tags, blacklist.require)) {
        if (blacklist.exclude.length === 0 || (!Danbooru.is_subset(tags, blacklist.exclude))) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  Danbooru.Blacklist.post_hide = function(post) {
    var $post = $(post);
    $post.addClass("blacklisted").addClass("blacklisted-active");
  }
  
  Danbooru.Blacklist.initialize_all = function() {
    if ($("#c-posts").length || $("#c-favorites").length || $("#c-pools").length) {
      Danbooru.Blacklist.parse_entries();
      
      if (Danbooru.Blacklist.apply() > 0) {
        Danbooru.Blacklist.update_sidebar();
      } else {
        $("#blacklist-box").hide();
      }
    }
  }
})();

$(document).ready(function() {
  Danbooru.Blacklist.initialize_all();
});
