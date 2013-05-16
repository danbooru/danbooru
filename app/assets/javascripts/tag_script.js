(function() {
  Danbooru.TagScript = {};

  Danbooru.TagScript.parse = function(script) {
    return script.match(/\[.+?\]|\S+/g);
  }

  Danbooru.TagScript.test = function(tags, predicate) {
    var split_pred = predicate.match(/\S+/g);
    var is_true = true;

    $.each(split_pred, function(i, x) {
      if (x[0] === "-") {
        if ($.inArray(x.substr(1, 100), tags)) {
          is_true = false;
        }
      } else {
        if (!$.inArray(x, tags)) {
          is_true = false;
        }
      }
    });

    return is_true;
  }

  Danbooru.TagScript.process = function(tags, command) {
    if (command.match(/^\[if/)) {
      var match = command.match(/\[if\s+(.+?)\s*,\s*(.+?)\]/)
      if (Danbooru.TagScript.test(tags, match[1])) {
        return Danbooru.TagScript.process(tags, match[2]);
      } else {
        return tags;
      }
    } else if (command === "[reset]") {
      return [];
    } else if (command[0] === "-" && !command.match(/^-pool:/i)) {
      return Danbooru.reject(tags, function(x) {return x === command.substr(1, 100)});
    } else {
      tags.push(command);
      return tags;
    }
  }

  Danbooru.TagScript.run = function(post_id, tag_script) {
    var commands = Danbooru.TagScript.parse(tag_script);
    var $post = $("#post_" + post_id);
    var old_tags = $post.data("tags");

    $.each(commands, function(i, x) {
      var array = String($post.data("tags")).match(/\S+/g);
      $post.data("tags", Danbooru.TagScript.process(array, x).join(" "));
    });

    Danbooru.Post.update(post_id, {"post[old_tag_string]": old_tags, "post[tag_string]": $post.data("tags")}, Danbooru.Post.update_title_with_data);
  }
})();
