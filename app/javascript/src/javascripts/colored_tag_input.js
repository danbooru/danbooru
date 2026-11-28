import Alpine from "alpinejs";
import { splitWords, tagCategoryPrefixes, wordAtCaret } from "./utility";

// Colors the tags in a tag textarea by category, and strikes through deprecated tags.
//
// A textarea can't color parts of its text, so its text is made transparent, and drawn again in colors by an overlay
// behind it. The overlay copies the textarea's font, padding, size, and scroll position, so the text lines up.
//
// Tag categories come from the page's tag lists, from tags picked in autocomplete, and otherwise from /tags.json.
export default class ColoredTagInput {
  static MAX_WORDS = 1_250; // Post::MAX_TAG_COUNT. Longer text isn't a real tag list, so it's shown uncolored.
  static MAX_LOOKUPS = 200; // Stop looking up tags in /tags.json after this many names.
  static MAX_URL_LENGTH = 4_000; // Well under the 8KB max URL length (see config/puma.rb).
  static MAX_NAME_LENGTH = 170; // TagNameValidator::MAX_TAG_LENGTH
  static TAG_LISTS = ["#tag-list", "#tag-box", "#related-tags-container"]; // Post tags, search tags, related tags.

  // The styles that decide where the text is drawn and where it wraps. The page's textarea CSS doesn't apply to the
  // overlay, so they're copied from the textarea.
  static COPIED_STYLES = [
    "fontFamily", "fontSize", "fontStyle", "fontWeight", "lineHeight", "letterSpacing", "wordSpacing", "tabSize",
    "textIndent", "textTransform", "whiteSpace", "overflowWrap", "wordBreak", "paddingTop", "paddingBottom",
    "paddingLeft", "borderTopWidth", "borderRightWidth", "borderBottomWidth", "borderLeftWidth",
  ];

  // @param root [HTMLElement] The `.colored-tag-input` div, holding the textarea and the overlay.
  constructor(root) {
    ColoredTagInput.categoryPrefixes ??= tagCategoryPrefixes();
    ColoredTagInput.wordRegexp ??= new RegExp(`^(-?)((?:${Object.keys(ColoredTagInput.categoryPrefixes).join("|")}):)?(.*)$`, "i");

    this.wrapper = root;
    this.textarea = root.querySelector("textarea");
    this.overlay = root.querySelector(".colored-tag-input-overlay");

    this.tags = new Map(); // Tag name => `{ category, isDeprecated }`, or null if there's no such tag.
    this.tagNames = new Set(); // The tag names in the textarea when it was last rendered.
    this.lookups = 0; // How many tag names have been looked up.
    this.isFetching = false;

    // Related tags and the quick edit form change the text without an input event, so `danbooru:update-tag-counter`
    // and `focus` also rerender, and recheck the page's tag lists in case the related tags have loaded. `blur` finishes
    // the word being typed, so it can be looked up.
    $(this.textarea).on("focus.danbooru danbooru:update-tag-counter.danbooru", () => this.addTagsFromPage());
    $(this.textarea).on("input.danbooru focus.danbooru blur.danbooru danbooru:update-tag-counter.danbooru", () => {
      this.render();
      this.fetchTags();
    });
    $(this.textarea).on("scroll.danbooru", () => this.syncScroll());
    $(this.textarea).on("autocompleteselect.danbooru", (event, ui) => this.addTagFromAutocomplete(ui.item));

    new ResizeObserver(() => {
      this.copyPosition();
      this.syncScroll();
    }).observe(this.textarea);

    this.addTagsFromPage();
    this.copyStyles();
    this.copyPosition();
    this.render();
    this.fetchTags();
  }

  // Redraw the overlay from the textarea's text, and remember its tag names for `fetchTags`. Text that's too long to
  // be a tag list is left uncolored.
  render() {
    let { value } = this.textarea;
    let words = splitWords(value);
    let isTooLong = words.length > ColoredTagInput.MAX_WORDS;

    this.wrapper.classList.toggle("colored-tag-input-disabled", isTooLong);

    if (isTooLong) {
      this.tagNames = new Set();
      this.overlay.replaceChildren();
      return;
    }

    this.tagNames = new Set(words.map(word => ColoredTagInput.parseWord(word).term.toLowerCase()));
    this.overlay.replaceChildren(...this.renderText(value));
    this.fitScrollbar();
    this.syncScroll();
  }

  // @param text [String] The textarea's text.
  // @returns [Array<String, HTMLElement>] The overlay's contents: the whitespace as text, and the words colored.
  renderText(text) {
    // "-art:bkub  1girl" => ["-art:bkub", "  ", "1girl"]. Words are at even indexes, and whitespace at odd ones.
    let nodes = text.split(/(\s+)/).flatMap((part, i) => {
      let isWord = i % 2 === 0 && part !== "";
      return isWord ? this.renderWord(ColoredTagInput.parseWord(part)) : [part];
    });

    // A trailing newline starts a new line in a textarea, but not in a div.
    if (text.endsWith("\n")) {
      nodes.push(" ");
    }

    return nodes;
  }

  // Split a word the way the server does (see PostEdit#tag and PostEdit#metatag): `-` is the only operator, category
  // prefixes are case-insensitive, and `~` and `(` are part of the tag name.
  //
  // "ART:bkub"  => { operator: "",  category: "ART:", term: "bkub" }
  // "-art:bkub" => { operator: "-", category: "art:", term: "bkub" }
  // "~art:bkub" => { operator: "",  category: "",     term: "~art:bkub" }
  //
  // @param word [String] A word in the textarea.
  // @returns [Object] The word's operator, category prefix, and tag name.
  static parseWord(word) {
    let [, operator, category = "", term] = word.match(ColoredTagInput.wordRegexp);
    return { operator, category, term };
  }

  // Color the category prefix by the category it sets, and the tag by its current category, struck through if it's
  // deprecated. Negated prefixes stay uncolored, because `-art:bkub` only removes bkub.
  //
  // @param parsed [Object] A word split by `parseWord`.
  // @returns [Array<String, HTMLElement>] The word as text and colored spans, e.g. ["", <span>art:</span>, "bkub"].
  renderWord({ operator, category, term }) {
    let tag = this.tags.get(term.toLowerCase());
    let setsCategory = category !== "" && operator === "";

    if (!tag && !setsCategory) {
      return [operator + category + term];
    }

    let nodes = [operator];

    if (setsCategory) {
      let categorySpan = document.createElement("span");
      categorySpan.className = `tag-type-${ColoredTagInput.categoryPrefixes[category.slice(0, -1).toLowerCase()]}`;
      categorySpan.append(category);
      nodes.push(categorySpan);
    } else {
      nodes.push(category);
    }

    if (tag) {
      let termSpan = document.createElement("span");
      termSpan.className = `tag-type-${tag.category}`;
      termSpan.classList.toggle("line-through", tag.isDeprecated);
      termSpan.append(term);
      nodes.push(termSpan);
    } else {
      nodes.push(term);
    }

    return nodes;
  }

  // Copy the textarea's font, padding, and borders to the overlay. They don't change after the page loads, so this is
  // only done once.
  copyStyles() {
    let style = window.getComputedStyle(this.textarea);
    ColoredTagInput.COPIED_STYLES.forEach(name => { this.overlay.style[name] = style[name]; });

    this.paddingRight = parseFloat(style.paddingRight);
    this.borderWidth = parseFloat(style.borderLeftWidth) + parseFloat(style.borderRightWidth);
  }

  // Copy the textarea's position and size to the overlay. Done again whenever the textarea is resized.
  copyPosition() {
    // offsetTop and offsetWidth round to whole pixels, which puts the text a pixel off at fractional positions.
    let textareaRect = this.textarea.getBoundingClientRect();
    let wrapperRect = this.wrapper.getBoundingClientRect();
    this.overlay.style.top = `${textareaRect.top - wrapperRect.top}px`;
    this.overlay.style.left = `${textareaRect.left - wrapperRect.left}px`;
    this.overlay.style.width = `${textareaRect.width}px`;
    this.overlay.style.height = `${textareaRect.height}px`;
    this.fitScrollbar();
  }

  // Leave room for the textarea's scrollbar, so the text wraps at the same place. Checked on every render, because the
  // scrollbar appears when the text gets long, without the textarea changing size.
  fitScrollbar() {
    let scrollbarWidth = Math.max(0, this.textarea.offsetWidth - this.textarea.clientWidth - this.borderWidth);
    this.overlay.style.paddingRight = `${this.paddingRight + scrollbarWidth}px`;
  }

  syncScroll() {
    this.overlay.scrollTop = this.textarea.scrollTop;
    this.overlay.scrollLeft = this.textarea.scrollLeft;
  }

  // Look up the tag names from the last render that we haven't seen yet in /tags.json, one request at a time, then
  // rerender with their colors.
  async fetchTags() {
    if (this.isFetching) {
      return;
    }

    let batch = this.nextBatch();
    if (batch.length === 0) {
      return;
    }

    // Failed lookups count toward the limit too, so a broken server doesn't get requests forever.
    this.lookups += batch.length;
    this.isFetching = true;

    let params = {
      search: { name_space: batch.join(" ") },
      only: "name,category,is_deprecated,aliased_tag[category,is_deprecated]",
      limit: batch.length,
    };
    let tags = await $.get("/tags.json", params).catch(() => null);
    this.isFetching = false;

    // If the request failed, leave the tags uncolored, and retry them on the next edit.
    if (tags === null) {
      return;
    }

    batch.forEach(name => this.tags.set(name, null));
    tags.forEach(tag => {
      let { category, is_deprecated } = tag.aliased_tag ?? tag;
      this.tags.set(tag.name, { category, isDeprecated: is_deprecated });
    });

    this.render();
    this.fetchTags(); // Look up the rest, if they didn't fit in one URL or were typed during the request.
  }

  // The word being typed is skipped, so half-typed tags like "hatsu" aren't looked up until the next word is started
  // or the textarea loses focus.
  //
  // @returns [Array<String>] The next tag names to look up: the ones not seen yet, up to the lookup limit, and as many
  //   as fit in one URL.
  nextBatch() {
    let typedTagName = this.typedTagName();
    let names = [...this.tagNames].filter(name => {
      return name !== typedTagName && ColoredTagInput.canBeTag(name) && !this.tags.has(name);
    });

    // Each name takes its encoded length in the URL, plus a "+" between names.
    let batch = [];
    let urlLength = 0;
    for (let name of names.slice(0, ColoredTagInput.MAX_LOOKUPS - this.lookups)) {
      urlLength += encodeURIComponent(name).length + 1;
      if (urlLength > ColoredTagInput.MAX_URL_LENGTH) {
        break;
      }
      batch.push(name);
    }

    return batch;
  }

  // @returns [String, null] The tag name the caret is in, e.g. "hatsune_miku" for "1girl hatsu|ne_miku" with the caret
  //   at |, or null if the textarea isn't focused or text is selected.
  typedTagName() {
    let { selectionStart, selectionEnd } = this.textarea;
    if (document.activeElement !== this.textarea || selectionStart !== selectionEnd) {
      return null;
    }

    let [before, after] = wordAtCaret(this.textarea);
    return ColoredTagInput.parseWord(before + after).term.toLowerCase();
  }

  // Tag names are printable ASCII, so other words aren't looked up. Metatags like "rating:s" are looked up, but aren't
  // found, so they stay uncolored like new tags.
  //
  // @param name [String] A tag name, e.g. "bkub".
  // @returns [Boolean] Whether a tag with this name could exist.
  static canBeTag(name) {
    return /^[!-~]+$/.test(name) && name.length <= ColoredTagInput.MAX_NAME_LENGTH;
  }

  // Remember the tags in the page's tag lists, e.g.:
  //
  //   <li class="tag-type-4" data-tag-name="hatsune_miku" data-is-deprecated="false">
  //
  // Tags elsewhere on the page are ignored, so user content like DText can't fake a tag's category.
  addTagsFromPage() {
    let selector = ColoredTagInput.TAG_LISTS.map(list => `${list} [data-tag-name][data-is-deprecated][class*='tag-type-']`).join(", ");

    $(selector).toArray().forEach(element => {
      let category = element.className.match(/(?:^|\s)tag-type-(\d+)(?:\s|$)/)?.[1];

      if (category !== undefined) {
        this.tags.set(element.dataset.tagName, { category: Number(category), isDeprecated: element.dataset.isDeprecated === "true" });
      }
    });
  }

  // Remember a tag picked in autocomplete, e.g.:
  //
  //   <li data-autocomplete-type="tag-word" data-autocomplete-category="4" data-autocomplete-is-deprecated="false">
  //
  // @param item [Object] The jQuery UI autocomplete item.
  addTagFromAutocomplete(item) {
    let type = item.html.attr("data-autocomplete-type");
    let category = item.html.attr("data-autocomplete-category");
    let isDeprecated = item.html.attr("data-autocomplete-is-deprecated");

    if (!type?.startsWith("tag")) {
      // Metatags like `rating:general` aren't tags, so don't look them up.
      this.tags.set(item.value.toLowerCase(), null);
    } else if (/^\d+$/.test(category) && isDeprecated !== undefined) {
      this.tags.set(item.value.toLowerCase(), { category: Number(category), isDeprecated: isDeprecated === "true" });
    }
  }
}

Alpine.data("coloredTagInput", (root) => ({
  input: new ColoredTagInput(root),
}));
