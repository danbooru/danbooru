import Autocomplete from "./autocomplete";
import Notice from "./notice";
import { uploadFilesOrURL } from "./utility";
import { computePosition, autoPlacement, inline, shift } from "@floating-ui/dom";

// @see app/components/dtext_editor_component.rb
export default class DTextEditor {
  // The key bindings for the DText editor.
  static KEYS = {
    "p": (editor) => editor.toggleMode(),
    "b": (editor) => editor.toggleBold(),
    "i": (editor) => editor.toggleItalic(),
    "u": (editor) => editor.toggleUnderline(),
    "s": (editor) => editor.toggleStrikethrough(),
    "k": (editor) => editor.toggleWikiLink(),
    "l": (editor) => editor.toggleNamedLink(),
    "{": (editor) => editor.toggleSearchLink(),
    "/": (editor) => editor.toggleSpoiler(),
    "q": (editor) => editor.toggleQuote(),
    "e": (editor) => editor.toggleExpand(),
    "m": (editor) => editor.toggleCode(),
  }

  // The list of URLs that will be converted to DText links when pasted into the editor.
  static SHORTLINKS = new Map([
    [/^\/artists\/(\d+)$/,              (id) => `artist #${id}`],
    [/^\/bulk_update_requests\/(\d+)$/, (id) => `bur #${id}`],
    [/^\/comments\/(\d+)$/,             (id) => `comment #${id}`],
    [/^\/forum_posts\/(\d+)$/,          (id) => `forum #${id}`],
    [/^\/forum_topics\/(\d+)$/,         (id) => `topic #${id}`],
    [/^\/media_assets\/(\d+)$/,         (id) => `asset #${id}`],
    [/^\/notes\/(\d+)$/,                (id) => `note #${id}`],
    [/^\/pools\/(\d+)$/,                (id) => `pool #${id}`],
    [/^\/posts\/(\d+)$/,                (id) => `post #${id}`],
    [/^\/wiki_pages\/([^.]+)$/,         (title) => `[[${title.replace(/_/g, " ")}]]`],
    [/^\/users\/(\d+)$/,                (id) => `user #${id}`],
  ]);

  root = null; // The root <div class="dtext-editor"> element.
  dtext = ""; // The text currently in the editor. This is the raw DText input, not the HTML preview.
  input = null; // The <input> or <textarea> element for DText input.
  autocomplete = null; // The jQuery UI autocomplete instance for the input element.
  mirror = null; // The mirror <div> element, used for tracking the current cursor position.
  mirrorRange = null; // The current selection range in the mirror element.

  mode = "edit"; // The current mode of the editor, either "edit" or "preview".
  uploading = false; // True if the editor is currently uploading files.
  previewLoading = false; // True if the editor is currently loading the preview HTML.
  emojiSearch = ""; // The current search term for the emoji picker.

  inline = false; // If true, the editor is in inline mode (only uses a single line <input> field instead of a <textarea>).
  mediaEmbeds = false; // Whether to enable media embeds in the preview.
  domains = []; // The list of the domains for the current site. Used for determining which links belong to the current site.

  // @param {HTMLElement} root - The root <div class="dtext-editor"> element of the DText editor.
  constructor(root) {
    this.root = root;
    this.input = root.querySelector("input.dtext, textarea.dtext");
    this.mirror = root.querySelector(".dtext-mirror");
    this.mirrorRange = document.createRange();
  }

  // @param {Boolean} inline - Whether the editor is in inline mode.
  // @param {Boolean} mediaEmbeds - Whether to enable media embeds in the preview.
  // @param {String[]} domains - The list of the domains for the current site.
  initialize({ inline = false, mediaEmbeds = false, domains = [] } = {}) {
    this.root.editor = this;
    this.inline = inline;
    this.mediaEmbeds = mediaEmbeds;
    this.domains = domains;

    this.initializeAutocomplete();
  }

  // Autocomplete @-mentions and :emoji: references.
  initializeAutocomplete() {
    $(this.input).autocomplete({
      select: (event, ui) => this.insertAutocompletion(event, ui.item.value, ui.item.html.get(0)),
      source: async (_req, respond) => respond(await this.autocompletions()),
      position: { using: () => this.positionAutocompleteMenu() },
      appendTo: $("#page"),
    });

    this.autocomplete = $(this.input).autocomplete("instance");
  }

  // Toggle between "edit" and "preview" modes.
  toggleMode() {
    this.mode = this.mode === "edit" ? "preview" : "edit";
  }

  // @returns {Boolean} True if the editor is in edit mode.
  get editMode() {
    return this.mode === "edit";
  }

  // @returns {Boolean} True if the editor is in preview mode.
  get previewMode() {
    return this.mode === "preview";
  }

  // Toggle the specified markup around the currently selected text.
  toggleBold()          { this.toggleInline("[b]", "[/b]"); }
  toggleItalic()        { this.toggleInline("[i]", "[/i]"); }
  toggleUnderline()     { this.toggleInline("[u]", "[/u]"); }
  toggleStrikethrough() { this.toggleInline("[s]", "[/s]"); }
  toggleWikiLink()      { this.toggleInline("[[", "]]"); }
  toggleNamedLink()     { this.toggleInline('"', '":[https://www.example.com]'); }
  toggleSearchLink()    { this.toggleInline("{{", "}}"); }
  toggleSpoiler()       { this.toggleInline("[spoiler]", "[/spoiler]"); }
  insertRule()          { this.insertMarkup("\n[hr]\n"); }
  toggleQuote()         { this.toggleBlock("[quote]", "[/quote]"); }
  toggleExpand()        { this.toggleBlock("[expand]", "[/expand]"); }
  toggleCode()          { this.toggleBlock("[code]", "[/code]"); }
  toggleNoDText()       { this.toggleBlock("[nodtext]", "[/nodtext]"); }

  // Toggle `startTag` and `endTag` around the currently selected text.
  toggleInline(startTag, endTag) {
    let selectedText = this.selectedText;
    let start = this.selectionStart;
    let end = this.selectionEnd;
    let [prefix, suffix] = this.expandedSelection(startTag, endTag);

    // If no text is selected, but we're inside a tag, then remove the nearest surrounding tags.
    if (this.selectedText.length === 0 && prefix.length > 0 && suffix.length > 0) {
      selectedText = `${prefix}${selectedText}${suffix}`;
      this.insertText(selectedText.substring(startTag.length, selectedText.length - endTag.length), start - prefix.length, end + suffix.length);

      // If the tag contained multiple words, select all the text between the tags.
      if (selectedText.match(/\s/)) {
        this.setSelectionRange(start - prefix.length, end + suffix.length - endTag.length - startTag.length);
      // If the tag contained a single word, preserve the cursor position and leave the word unselected.
      } else {
        this.setCursorPosition(start - startTag.length);
      }
    // If the selected text includes the tags, remove them.
    } else if (selectedText.startsWith(startTag) && selectedText.endsWith(endTag)) {
      this.insertText(selectedText.substring(startTag.length, selectedText.length - endTag.length), start, end);
    // If the selected text is immediately surrounded by the tags, remove them.
    } else if (this.dtext.substring(start - startTag.length, end + endTag.length) === `${startTag}${selectedText}${endTag}`) {
      this.insertText(selectedText, start - startTag.length, end + endTag.length);
    // Otherwise, insert the tags around the selected text or the current word.
    } else {
      this.insertMarkup(startTag, endTag);
    }
  }

  toggleBlock(startTag, endTag) {
    this.toggleInline(`\n${startTag}\n`, `\n${endTag}\n`);
  }

  // Insert `startTag` and `endTag` around the currently selected text, or around the current word if no text is
  // selected. Surrounding whitespace is ignored.
  insertMarkup(startTag, endTag = "") {
    let selectedText = this.selectedText;

    // If no text is selected, insert the tags around the current word.
    if (selectedText.length === 0) {
      let prefix = this.selectionPrefix.match(/[a-zA-Z0-9_]*$/)[0] || "";
      let suffix = this.selectionSuffix.match(/^[a-zA-Z0-9_]*/)[0] || "";

      let start = this.selectionStart - prefix.length;
      let end = this.selectionEnd + suffix.length;
      let caret = this.selectionStart + startTag.length;

      selectedText = `${prefix}${suffix}`;
      this.insertText(`${startTag}${selectedText}${endTag}`, start, end);
      this.setCursorPosition(caret);

    // If text is selected, insert the tags around the selected text, ignoring surrounding whitespace.
    } else {
      let start = this.selectionStart + (selectedText.length - selectedText.trimStart().length);
      let end = this.selectionEnd - (selectedText.length - selectedText.trimEnd().length);

      selectedText = selectedText.trim();
      this.insertText(`${startTag}${selectedText}${endTag}`, start, end);
      this.setSelectionRange(start + startTag.length, start + startTag.length + selectedText.length);
    }
  }

  // Handle keyboard shortcuts.
  onKeyDown(event) {
    let handler = DTextEditor.KEYS[event.key.toLowerCase()];

    if (event.ctrlKey && !event.shiftKey && handler) {
      handler(this);
      event.preventDefault();
    } else if (["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) {
      // XXX Hack to prevent the autocomplete menu from popping up when the user is navigating with the keyboard.
      event.stopPropagation();
    }
  }

  // Handle paste events. Convert links to DText format and inserts pasted images as embedded media assets.
  onPaste(event) {
    let text = event.clipboardData.getData("text");

    if (event.clipboardData.files.length > 0) {
      this.insertImages(event.clipboardData.files);
    } else if (URL.canParse(text) && this.domains.includes(URL.parse(text).hostname)) {
      this.insertUrl(text);
      event.preventDefault();
    }
  }

  // Insert a URL. If the URL is a full link (e.g. "https://example.com/posts/123"), it will be converted to a shortlink (e.g. "post #123").
  insertUrl(text) {
    let url = URL.parse(text);
    let path = decodeURIComponent(url.pathname);
    let [regex, formatter] = DTextEditor.SHORTLINKS.entries().find(([regex, _formatter]) => path.match(regex)) || [];
    let dtext = formatter?.(path.match(regex)[1]);

    if (dtext) {
      this.insertText(dtext);
    } else {
      this.insertText(text);
    }
  }

  // Insert the specified text, replacing the text between the `start` and `end` positions (by default, the currently selected text).
  insertText(text, start = this.selectionStart, end = this.selectionEnd) {
    let selected = this.selectionStart !== this.selectionEnd;

    this.focus();

    if (start !== this.selectionStart || end !== this.selectionEnd) {
      this.setSelectionRange(start, end);
    }

    if (text.length > 0) {
      // Use execCommand so that the undo history is updated.
      let success = document.execCommand("insertText", false, text);
      if (!success) {
        // insertText is not supported by the browser.
        // Fall back to setRangeText.
        this.input.setRangeText(text, start, end, "select");
        if (!selected) {
          this.setSelectionRange(start + text.length, start + text.length);
        }
      }
    }

    // Select the new text if the replaced text was previously selected.
    if (selected) {
      this.setSelectionRange(start, start + text.length);
    }
  }

  // Insert text for a block-level element. Ensures the text is on its own line.
  insertBlockText(text) {
    // Prepend newlines if we're not at the start of a line.
    if (!/(^|\n)\s*$/.test(this.selectionPrefix)) {
      text = `\n${text}`;
    }

    // Append newlines if we're not at the end of a line.
    if (!/^\s*(\n|$)/.test(this.selectionSuffix)) {
      text = `${text}\n`;
    }

    this.insertText(text);
  }

  // Upload a list of files or a URL and insert the resulting images as embedded media assets (e.g. `* !asset #123`).
  //
  // @param {String|File[]} filesOrURL - The list of files or the URL to upload.
  // @param {String} size - Whether to insert the images as a gallery of thumbnail images ("small") or as full-size images ("large").
  // @param {String} caption - The caption to use for the images.
  async insertImages(filesOrURL, size = "small", caption = "") {
    if (!this.mediaEmbeds) {
      return;
    }

    try {
      let prefix = size === "small" ? "* " : "";
      let suffix = caption.length > 0 ? `: ${caption}` : "";

      this.uploading = true;
      Danbooru.Shortcuts.hide_tooltips(); // Hide the insert image menu.
      let upload = await uploadFilesOrURL(filesOrURL);
      this.uploading = false;

      let dtext = upload.upload_media_assets.map(uma => {
        if (uma.media_asset.post) {
          return `${prefix}!post #${uma.media_asset.post.id}${suffix}`;
        } else {
          return `${prefix}!asset #${uma.media_asset.id}${suffix}`;
        }
      }).join("\n");

      this.insertBlockText(dtext);
    } catch (error) {
      Notice.error(error.message);
    } finally {
      this.uploading = false;
    }
  }

  // Insert the emoji at the current cursor position.
  insertEmoji(emoji) {
    this.insertText(`:${emoji}:`);
    Danbooru.Shortcuts.hide_tooltips();
  }

  // @returns {Boolean} True if the given emoji matches the current search term in the emoji picker.
  emojiMatches(emoji) {
    return emoji.toLowerCase().includes(this.emojiSearch.toLowerCase().replace(/[^a-zA-Z0-9]/g, ''));
  }

  // @returns {Boolean} True if the editor is currently loading (either uploading files or loading the preview).
  get loading() {
    return this.uploading || this.previewLoading;
  }

  // Set the focus to the input element.
  focus() {
    this.input.focus();
  }

  // @returns {Number} The start position of the currently selected text. If no text is selected, this is the position of the cursor.
  get selectionStart() {
    return this.input.selectionStart;
  }

  // @returns {Number} The end position of the currently selected text. If no text is selected, this is the position of the cursor.
  get selectionEnd() {
    return this.input.selectionEnd;
  }

  // @param {Number} start - The start position of the selected text.
  // @param {Number} end - The end position of the selected text.
  setSelectionRange(start, end) {
    this.input.setSelectionRange(start, end);
  }

  // @param {Number} position - The position to set the cursor to in the text.
  setCursorPosition(position) {
    this.setSelectionRange(position, position);
  }

  // @returns {String} The currently selected text in the <textarea> element.
  get selectedText() {
    return this.dtext.substring(this.selectionStart, this.selectionEnd);
  }

  // @returns {String} The text before the current selection.
  get selectionPrefix() {
    return this.dtext.substring(0, this.selectionStart);
  }

  // @returns {String} The text after the current selection.
  get selectionSuffix() {
    return this.dtext.substring(this.selectionEnd);
  }

  // @returns {String} The line of text before the current selection.
  get selectionPrefixLine() {
    return this.selectionPrefix.split(/[\r\n]+/).at(-1) || "";
  }

  // @returns {String} The line of text after the current selection.
  get selectionSuffixLine() {
    return this.selectionSuffix.split(/[\r\n]+/).at(0) || "";
  }

  // @returns {Array} The current selection expanded outwards to include the nearest start and end tags on the current line (if present).
  expandedSelection(startTag, endTag) {
    let prefix = "";
    let suffix = "";
    let prefixLine = this.selectionPrefixLine;
    let suffixLine = this.selectionSuffixLine;

    let start = prefixLine.lastIndexOf(startTag);
    if (start !== -1 && start > prefixLine.lastIndexOf(endTag)) {
      prefix = prefixLine.substring(start);
    }

    let end = suffixLine.indexOf(endTag);
    if (end !== -1 && (end < suffixLine.indexOf(startTag) || suffixLine.indexOf(startTag) === -1)) {
      suffix = suffixLine.substring(0, end + endTag.length);
    }

    return [prefix, suffix];
  }

  // @returns {Object} - The autocompletion type and context for the current word, if it's autocompleteable, or nothing if the word can't be autocompleted.
  get autocompletionQuery() {
    let match;
    let prefix = "";
    let suffix = "";
    let fullPrefix = "";
    let fullSuffix = "";
    let formatCompletion = word => word;

    if (match = this.selectionPrefixLine.match(/(\[\[)([^\[\]\|]+?)$/)) {
      let label = "";
      prefix = match[2];
      fullPrefix = `${match[1]}${prefix}`;

      if (match = this.selectionSuffixLine.match(/^([^\[\]\|]*?)(\|[^\]]*?)?\]\]/)) {
        suffix = match[1];
        fullSuffix = match[0];
        label = match[2] || "";
      } else if (match = this.selectionSuffixLine.match(/^\S*/)) {
        suffix = match[0];
        fullSuffix = suffix;
      }

      return { type: "tag", term: `${prefix}${suffix}`.toLowerCase(), fullTerm: `${fullPrefix}${fullSuffix}`, prefix, fullPrefix, formatCompletion: (_word, properName) => `[[${properName}${label}]]` };
    } else if (match = this.selectionPrefixLine.match(/(\{\{[^\{\}\|]*?)(\S*)$/)) {
      let label = "";
      let lhs = match[1];
      prefix = match[2];
      fullPrefix = `${lhs}${prefix}`;

      if (match = this.selectionSuffixLine.match(/^([^\{\}\|]*?)(\|[^\}]*?)?\}\}/)) {
        suffix = match[1];
        fullSuffix = match[0];
        label = match[2] || "";
      } else if (match = this.selectionSuffixLine.match(/^\S*/)) {
        suffix = match[0];
        fullSuffix = suffix;
      }

      return { type: "tag_query", term: `${prefix}${suffix}`.toLowerCase(), fullTerm: `${fullPrefix}${fullSuffix}`, prefix, fullPrefix, formatCompletion: word => `${lhs}${word}${label}}}` };
    } else if (match = this.selectionPrefixLine.match(/([ \r\n/\\()[\]{}<>]|^):([a-zA-Z0-9_]*)$/)) {
      prefix = match[2];
      suffix = this.selectionSuffixLine.match(/^\S*/)[0];
      fullPrefix = `:${prefix}`;

      return { type: "emoji", term: `${prefix}${suffix}`, fullTerm: `${fullPrefix}${suffix}`, prefix, fullPrefix, formatCompletion };
    // See user_name_validator.rb for the username rules.
    } else if (match = this.selectionPrefixLine.match(/([^a-zA-Z0-9\[\{]|^)@([a-zA-Z0-9_.\-\p{Script=Han}\p{Script=Hangul}\p{Script=Hiragana}\p{Script=Katakana}]+)$/u)) {
      prefix = match[2];
      suffix = this.selectionSuffixLine.match(/^\S*/)[0];
      fullPrefix = `@${prefix}`;

      return { type: "mention", term: `${prefix}${suffix}`, fullTerm: `${fullPrefix}${suffix}`, prefix, fullPrefix, formatCompletion };
    } else {
      return {};
    }
  }

  // @return {Array} - The autocompletions for the currently typed word, or nothing if the word can't be autocompleted.
  async autocompletions() {
    let query = this.autocompletionQuery;

    if (query.type === "tag") {
      return await Autocomplete.autocomplete_source(query.term, "tag");
    } else if (query.type === "tag_query") {
      return await Autocomplete.autocomplete_source(query.term, "tag_query");
    } else if (query.type === "mention") {
      return await Autocomplete.autocomplete_source(query.term, "mention");
    } else if (query.type === "emoji") {
      return await Autocomplete.autocomplete_source(query.term, "emoji", { limit: 50, allowEmpty: true });
    } else {
      return [];
    }
  }

  // Insert the selected autocompletion at the current cursor position.
  insertAutocompletion(event, completion, item) {
    let query = this.autocompletionQuery;
    let properName = item.getAttribute("data-autocomplete-proper-name");
    let formattedCompletion = query.formatCompletion(completion, properName);
    let start = 0;
    let end = 0;

    // If the user typed capitals, keep what they typed to preserve their capitalization. Otherwise, replace the whole query.
    if (query.prefix.match(/[A-Z]/) && completion.startsWith(query.prefix.toLowerCase().replace(/ /g, "_"))) {
      start = this.selectionStart;
      end = start + (query.fullTerm.length - query.fullPrefix.length);
      formattedCompletion = formattedCompletion.substring(query.fullPrefix.length);
    } else {
      start = this.selectionStart - query.fullPrefix.length;
      end = start + query.fullTerm.length;
    }

    // Add a space after the completion. If there's already a space, move the cursor past it instead.
    formattedCompletion += " ";
    if (this.dtext[end] === " ") {
      end += 1;
    }

    this.insertText(formattedCompletion, start, end);
    event.preventDefault();
  }

  // Position the autocompletion menu below the cursor.
  positionAutocompleteMenu() {
    let menu = this.autocomplete.menu.element.get(0);

    computePosition(this.queryRange, menu, {
      placement: "bottom-start",
      middleware: [
        inline(),
        autoPlacement({
          allowedPlacements: ["bottom-start", "top-start"],
        }),
        shift({
          boundary: $("#page").get(0),
        }),
      ]
    }).then(({ x, y }) => {
      menu.style.top = y + "px";
      menu.style.left = x + "px";
    });
  }

  // @returns {Range} The range of text that corresponds to the current autocompletion query.
  get queryRange() {
    let query = this.autocompletionQuery;
    let queryLength = query.prefix?.length || 0;
    let start = this.selectionStart - queryLength;
    let end = start + queryLength;

    return this.textRange(start, end);
  }

  // Get a range of text from the editor, used for computing the screen position of the selected text.
  //
  // @param {Number} start - The start position of the range (in characters from the start of the text).
  // @param {Number} end - The end position of the range (in characters from the start of the text).
  // @returns {Range} The range of text.
  textRange(start = this.selectionStart, end = this.selectionEnd) {
    this.mirror.scrollTop = this.input.scrollTop;
    this.mirrorRange.setStart(this.mirror.childNodes[0], start);
    this.mirrorRange.setEnd(this.mirror.childNodes[0], end);

    return this.mirrorRange;
  }

  // @returns {String} The HTML representation of the DText input.
  async html() {
    if (this.previewMode) {
      return await this.fetchHtml();
    } else {
      return "";
    }
  }

  // @returns {String} The HTML representation of the DText input.
  async fetchHtml() {
    this.previewLoading = true;

    let html = await $.post("/dtext_preview", {
      body: this.dtext,
      inline: this.inline,
      media_embeds: this.mediaEmbeds,
    });

    this.previewLoading = false;
    return html;
  }
}
