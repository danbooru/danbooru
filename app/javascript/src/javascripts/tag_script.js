import Utility from './utility'
import Post from './posts.js.erb'

let TagScript = {};

TagScript.parse = function(script) {
  return script.match(/\[.+?\]|\S+/g);
}

TagScript.test = function(tags, predicate) {
  var split_pred = predicate.match(/\S+/g);
  var is_true = true;

  $.each(split_pred, function(i, x) {
    if (x[0] === "-") {
      if ($.inArray(x.substr(1, 100), tags)) {
        is_true = false;
      }
    } else if (!$.inArray(x, tags)) {
      is_true = false;
    }
  });

  return is_true;
}

TagScript.process = function(tags, command) {
  if (command.match(/^\[if/)) {
    var match = command.match(/\[if\s+(.+?)\s*,\s*(.+?)\]/);
    if (TagScript.test(tags, match[1])) {
      return TagScript.process(tags, match[2]);
    } else {
      return tags;
    }
  } else if (command === "[reset]") {
    return [];
  } else if (command[0] === "-" && !command.match(/^(?:-pool|-parent|-fav|-favgroup):/i)) {
    return Utility.reject(tags, function(x) {return x === command.substr(1, 100)});
  } else {
    tags.push(command);
    return tags;
  }
}

TagScript.run = function(post_id, tag_script) {
  var commands = TagScript.parse(tag_script);
  var $post = $("#post_" + post_id);
  var old_tags = $post.data("tags");

  $.each(commands, function(i, x) {
    var array = String($post.data("tags")).match(/\S+/g);
    $post.data("tags", TagScript.process(array, x).join(" "));
  });

  Post.update(post_id, {"post[old_tag_string]": old_tags, "post[tag_string]": $post.data("tags")});
}

export default TagScript
