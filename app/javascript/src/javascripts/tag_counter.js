import Post from "./posts";
import Utility from "./utility";
import uniq from "lodash/uniq";

export default class TagCounter {
  static highCount = Post.HIGH_TAG_COUNT;

  constructor($element) {
    this.$element = $element;
    this.$target.on("input", (event) => this.update(event));
    this.update();
  }

  update() {
    this.$element.find(".tag-count").text(`${this.tagCount} / ${TagCounter.highCount} tags`);
  }

  get $target() {
    return $(this.$element.attr("data-for"));
  }

  get tagCount() {
    let tagString = this.$target.val().toLowerCase();
    let tags = uniq(Utility.splitWords(tagString));
    return tags.length;
  }

  static initialize() {
    $("[data-tag-counter]").toArray().forEach(element => {
      new TagCounter($(element));
    });
  }
}

$(TagCounter.initialize);
