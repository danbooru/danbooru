import { h, Component, render } from "preact";
import { observable, computed, action } from "mobx";
import { observer } from "mobx-react";

import Utility from "./utility";

export default @observer class TagCounter extends Component {
  static lowCount = 10;
  static highCount = 20;

  @observable tagCount = 0;

  componentDidMount() {
    $(this.props.tags).on("input", this.updateCount);
    this.updateCount();
  }

  render() {
    return (
      <span class="tag-counter">
        <span class="tag-count">{this.tagCount}</span> / {TagCounter.highCount} tags
        <i class={`far fa-${this.emoji}`}></i>
      </span>
    );
  }

  @action.bound updateCount() {
    this.tagCount = Utility.regexp_split($(this.props.tags).val()).length;
  }

  @computed get emoji() {
    if (this.tagCount < TagCounter.lowCount) {
      return "frown";
    } else if (this.tagCount >= TagCounter.lowCount && this.tagCount < TagCounter.highCount) {
      return "meh";
    } else {
      return "smile";
    }
  }

  static initialize() {
    $("[data-tag-counter]").toArray().forEach(element => {
      let target = $($(element).attr("data-for")).get(0);
      render(h(TagCounter, { tags: target }), element);
    });
  }
}

$(TagCounter.initialize);
