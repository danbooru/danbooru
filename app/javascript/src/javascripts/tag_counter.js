import Utility from "./utility";
import uniq from "lodash/uniq";

export default class TagCounter {
  static lowCount = 10;
  static highCount = 20;

  constructor($element) {
    this.$element = $element;
    this.$target.on("input", (event) => this.update(event));
    this.update();
  }

  update() {
    this.$element.find(".tag-count").text(`${this.tagCount} / ${TagCounter.highCount} tags`);
    this.$element.find("img").attr("src", `/images/${this.iconName}.png`);
  }

  get $target() {
    return $(this.$element.attr("data-for"));
  }

  get tagCount() {
    let tagString = this.$target.val().toLowerCase();
    let tags = uniq(Utility.splitWords(tagString));
    return tags.length;
  }

  get iconName() {
    if (this.tagCount < TagCounter.lowCount) {
      return "blobglare";
    } else if (this.tagCount >= TagCounter.lowCount && this.tagCount < TagCounter.highCount) {
      return "blobthinkingglare";
    } else {
      return "blobaww";
    }
  }

  static initialize() {
    $("[data-tag-counter]").toArray().forEach(element => {
      new TagCounter($(element));
    });
  }
}

$(TagCounter.initialize);
