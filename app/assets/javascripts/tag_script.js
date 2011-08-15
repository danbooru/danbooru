TagScript = {
  parse: function(script) {
    return script.match(/\[.+?\]|\S+/g);
  },

  test: function(tags, predicate) {
    var split_pred = predicate.match(/\S+/g);
    var is_true = true;

    split_pred.each(function(x) {
      if (x[0] == "-") {
        if (tags.include(x.substr(1, 100))) {
          is_true = false;
          throw $break;
        }
      } else {
        if (!tags.include(x)) {
          is_true = false;
          throw $break;
        }
      }
    })

    return is_true
  },

  process: function(tags, command) {
    if (command.match(/^\[if/)) {
      var match = command.match(/\[if\s+(.+?)\s*,\s*(.+?)\]/)
      if (TagScript.test(tags, match[1])) {
        return TagScript.process(tags, match[2]);
      } else {
        return tags;
      }
    } else if (command == "[reset]") {
      return [];
    } else if (command[0] == "-") {
      return tags.reject(function(x) {return x == command.substr(1, 100)})
    } else {
      tags.push(command)
      return tags;
    }
  },

  run: function(post_id, tag_script) {
    var commands = TagScript.parse(tag_script);
    var post = Post.posts.get(post_id);
    var old_tags = post.tags.join(" ");

    commands.each(function(x) {
      post.tags = TagScript.process(post.tags, x);
    })

    Post.update(post_id, {"post[old_tags]": old_tags, "post[tags]": post.tags.join(" ")});
  }
}