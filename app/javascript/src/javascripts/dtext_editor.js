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

  // Toggle `startTag` and `endTag` around the currently selected text.
  toggleInline(startTag, endTag) {
    let selectedText = this.selectedText;
    let start = this.input.selectionStart;
    let end = this.input.selectionEnd;

    if (selectedText.startsWith(startTag) && selectedText.endsWith(endTag)) {
      this.input.setRangeText(selectedText.substring(startTag.length, selectedText.length - endTag.length), start, end, "select");
      this.input.focus();
    } else if (this.input.value.substring(start - startTag.length, end + endTag.length) === `${startTag}${selectedText}${endTag}`) {
      this.input.setRangeText(selectedText, start - startTag.length, end + endTag.length, "select");
      this.input.focus();
    } else {
      this.insertMarkup(startTag, endTag);
    }
  }

  toggleBlock(startTag, endTag) {
    this.toggleInline(`\n${startTag}\n`, `\n${endTag}\n`);
  }

  // Insert `startTag` and `endTag` around the currently selected text. Leading or trailing whitespace is not included in the selection.
  insertMarkup(startTag, endTag = "") {
    let selectedText = this.selectedText;
    let start = this.input.selectionStart + (selectedText.length - selectedText.trimStart().length);
    let end = this.input.selectionEnd - (selectedText.length - selectedText.trimEnd().length);

    selectedText = selectedText.trim();
    this.input.setRangeText(`${startTag}${selectedText}${endTag}`, start, end);
    this.input.setSelectionRange(start + startTag.length, start + startTag.length + selectedText.length);
    this.input.focus();
  }

  // Handle keyboard shortcuts.
  onKeyDown(event) {
    if (event.ctrlKey && DTextEditor.KEYS[event.key]) {
      let handler = DTextEditor.KEYS[event.key];
      handler(this);
      event.preventDefault();
    }
  }

  // @returns {String} The currently selected text in the <textarea> element.
  get selectedText() {
    return this.input.value.substring(this.input.selectionStart, this.input.selectionEnd);
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
