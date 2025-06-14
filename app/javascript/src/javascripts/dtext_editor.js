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

  root = null; // The root <div class="dtext-editor"> element.
  input = null; // The <input> or <textarea> element for DText input.
  mode = "edit"; // The current mode of the editor, either "edit" or "preview".
  _html = ""; // The cached HTML representation of the DText input.

  // @param {HTMLElement} root - The root <div class="dtext-editor"> element of the DText editor.
  constructor(root) {
    this.root = root;
    this.input = root.querySelector("input.dtext, textarea.dtext");
  }

  initialize() {
    this.root.editor = this;
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
    let start = this.input.selectionStart;
    let end = this.input.selectionEnd;
    let [prefix, suffix] = this.expandedSelection(startTag, endTag);

    // If no text is selected, but we're inside a tag, then remove the nearest surrounding tags.
    if (this.selectedText.length === 0 && prefix.length > 0 && suffix.length > 0) {
      selectedText = `${prefix}${selectedText}${suffix}`;
      this.input.setRangeText(selectedText.substring(startTag.length, selectedText.length - endTag.length), start - prefix.length, end + suffix.length, "select");

      // If the cursor was inside a single word, preserve the cursor position and leave the word unselected.
      if (!selectedText.match(/\s/)) {
        this.input.setSelectionRange(start - startTag.length, start - startTag.length);
      }

      this.input.focus();
    // If the selected text includes the tags, remove them.
    } else if (selectedText.startsWith(startTag) && selectedText.endsWith(endTag)) {
      this.input.setRangeText(selectedText.substring(startTag.length, selectedText.length - endTag.length), start, end, "select");
      this.input.focus();
    // If the selected text is immediately surrounded by the tags, remove them.
    } else if (this.input.value.substring(start - startTag.length, end + endTag.length) === `${startTag}${selectedText}${endTag}`) {
      this.input.setRangeText(selectedText, start - startTag.length, end + endTag.length, "select");
      this.input.focus();
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

      let start = this.input.selectionStart - prefix.length;
      let end = this.input.selectionEnd + suffix.length;
      let caret = this.input.selectionStart + startTag.length;

      selectedText = `${prefix}${suffix}`;
      this.input.setRangeText(`${startTag}${selectedText}${endTag}`, start, end);
      this.input.setSelectionRange(caret, caret);

    // If text is selected, insert the tags around the selected text, ignoring surrounding whitespace.
    } else {
      let start = this.input.selectionStart + (selectedText.length - selectedText.trimStart().length);
      let end = this.input.selectionEnd - (selectedText.length - selectedText.trimEnd().length);

      selectedText = selectedText.trim();
      this.input.setRangeText(`${startTag}${selectedText}${endTag}`, start, end);
      this.input.setSelectionRange(start + startTag.length, start + startTag.length + selectedText.length);
    }

    this.input.focus();
  }

  // Handle keyboard shortcuts.
  onKeyDown(event) {
    let handler = DTextEditor.KEYS[event.key.toLowerCase()];

    if (event.ctrlKey && !event.shiftKey && handler) {
      handler(this);
      event.preventDefault();
    }
  }

  // @returns {String} The currently selected text in the <textarea> element.
  get selectedText() {
    return this.input.value.substring(this.input.selectionStart, this.input.selectionEnd);
  }

  // @returns {String} The text before the current selection.
  get selectionPrefix() {
    return this.input.value.substring(0, this.input.selectionStart);
  }

  // @returns {String} The text after the current selection.
  get selectionSuffix() {
    return this.input.value.substring(this.input.selectionEnd);
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

  // @returns {String} The cached HTML representation of the DText input.
  async html() {
    if (this.previewMode) {
      this._html = await this.fetchHtml();
    }

    return this._html;
  }

  // @returns {String} The HTML representation of the DText input.
  async fetchHtml() {
    this.loading = true;

    let html = await $.post("/dtext_preview", {
      body: this.input.value,
      inline: this.root.dataset.inline === "true",
      media_embeds: this.root.dataset.mediaEmbeds === "true",
    });

    this.loading = false;
    return html;
  }
}
