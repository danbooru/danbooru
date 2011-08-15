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
        if (tags.include(x.substr(1, 100))) {
          is_true = false;
        }
      } else {
        if (!tags.include(x)) {
          is_true = false;
        }
      }
    });

    return is_true;
  }

  Danbooru.TagScript.process = function(tags, command) {
    if (command.match(/^\[if/)) {
      var match = command.match(/\[if\s+(.+?)\s*,\s*(.+?)\]/)
      if (this.test(tags, match[1])) {
        return this.process(tags, match[2]);
      } else {
        return tags;
      }
    } else if (command === "[reset]") {
      return [];
    } else if (command[0] === "-") {
      return tags.reject(function(x) {return x == command.substr(1, 100)})
    } else {
      tags.push(command)
      return tags;
    }
  }

  Danbooru.TagScript.run = function(post_id, tag_script) {
    var commands = this.parse(tag_script);
    var post = Post.posts.get(post_id);
    var old_tags = post.tags.join(" ");

    $.each(commands, function(i, x) {
      post.tags = Danbooru.TagScript.process(post.tags, x);
    })

    Danbooru.Post.update(post_id, {"post[old_tags]": old_tags, "post[tags]": post.tags.join(" ")});
  }
})();
