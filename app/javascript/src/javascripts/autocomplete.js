import { clamp, isBeforeInputEventAvailable }  from './utility'
import UndoStack from './undo_stack';
import Utility from './utility';

let Autocomplete = {};

Autocomplete.VERSION = 3; // This should be bumped whenever the /autocomplete API changes in order to invalid client caches.
Autocomplete.MAX_RESULTS = 20;

Autocomplete.WHITESPACE = ' \\t\\r\\n';
Autocomplete.WORD_SEPARATORS = Autocomplete.WHITESPACE + '_()\\[\\]{}<>`\'"-/;:,.?!';
Autocomplete.PREV_WORD_REGEXP = new RegExp(`[^${Autocomplete.WORD_SEPARATORS}]*[${Autocomplete.WORD_SEPARATORS}]*$`);
Autocomplete.NEXT_WORD_REGEXP = new RegExp(`^[^${Autocomplete.WORD_SEPARATORS}]*[${Autocomplete.WORD_SEPARATORS}]*`);

Autocomplete.initialize_all = function() {
  $.widget("ui.autocomplete", $.ui.autocomplete, {
    options: {
      delay: 0,
      minLength: 1,
      autoFocus: false,
      focus: function() { return false; },
      classes: { "ui-autocomplete": "absolute cursor-pointer max-w-480px max-h-480px text-sm border shadow-lg thin-scrollbar", }
    },
    _create: function() {
      this.element.on("keydown.Autocomplete.tab", null, "tab", Autocomplete.on_tab);
      this._super();
    },
    _renderItem: Autocomplete.render_item,
    search: function(value, event) {
      if (event && (event.type !== "input" || !event.originalEvent || event.originalEvent.inputType === "")) {
        // Ignore keydown events such as arrows keys, shift, ctrl, etc, and fake input events not triggered by the user.
        return;
      }

      if ($(this).data("ui-autocomplete")) {
        $(this).data("ui-autocomplete").menu.bindings = $();
      }
      this._super(value, event);
    },
  });

  this.initialize_tag_autocomplete();
  this.initialize_fields($('[data-autocomplete="tag"]'), "tag");
  this.initialize_fields($('[data-autocomplete="artist"]'), "artist");
  this.initialize_fields($('[data-autocomplete="pool"]'), "pool");
  this.initialize_fields($('[data-autocomplete="user"]'), "user");
  this.initialize_fields($('[data-autocomplete="wiki-page"]'), "wiki_page");
  this.initialize_fields($('[data-autocomplete="favorite-group"]'), "favorite_group");
  this.initialize_fields($('[data-autocomplete="saved-search-label"]'), "saved_search_label");
}

Autocomplete.initialize_fields = function($fields, type) {
  $fields.autocomplete({
    select: function(event, ui) {
      Autocomplete.insert_completion(this, ui.item.value);
      return false;
    },
    source: async function(request, respond) {
      let results = await Autocomplete.autocomplete_source(request.term, type);
      respond(results);
    },
  });
};

Autocomplete.initialize_tag_autocomplete = function() {
  var $fields_multiple = $('[data-autocomplete="tag-query"], [data-autocomplete="tag-edit"]');

  $fields_multiple.autocomplete({
    select: function(event, ui) {
      Autocomplete.insert_completion(this, ui.item.value);
      return false;
    },
    source: async function(req, resp) {
      let term = Autocomplete.current_term(this.element);
      let results = await Autocomplete.autocomplete_source(term, "tag_query");
      resp(results);
    }
  });

  UndoStack.initialize_fields($fields_multiple);

  if (isBeforeInputEventAvailable()) {
    $fields_multiple.on("beforeinput", function(e) {
      if (!e || !e.originalEvent) {
        return;
      }
      let target = e.target;
      let event = e.originalEvent;

      if (event.inputType == "deleteWordBackward" || event.inputType == "deleteWordForward") {
        // Ctrl+Backspace or Ctrl+Delete were pressed. Delete an entire tag before/after the caret.
        let caret = target.selectionStart;
        var before_caret_text = target.value.substring(0, caret);
        var after_caret_text = target.value.substring(caret);
        if (event.inputType == "deleteWordBackward") {
          before_caret_text = before_caret_text.replace(Autocomplete.PREV_WORD_REGEXP, function(match) {
            if (!match.startsWith(" ") && match.endsWith(" ")) {
              // Add an extra space after the caret when deleting the final word in a tag.
              after_caret_text = " " + after_caret_text;
            }
            return "";
          });
        } else if (event.inputType == "deleteWordForward") {
          after_caret_text = after_caret_text.replace(Autocomplete.NEXT_WORD_REGEXP, function(match) {
            if (!match.startsWith(" ") && match.endsWith(" ")) {
              // Add an extra space after the caret when deleting the final word in a tag.
              return " ";
            }
            return "";
          });
        }
        $(target).replaceFieldText(before_caret_text + after_caret_text);
        target.selectionStart = target.selectionEnd = before_caret_text.length;

        $(target).autocomplete("search"); // Manually trigger autocomplete because programmatically editing the field won't trigger it.
        e.preventDefault();
      }
    });
  }

  Utility.keydown("ctrl+left", "cursor_word_left", e => {
    Autocomplete.moveCursorWordLeft(e.target);
    e.preventDefault();
  }, $fields_multiple);

  Utility.keydown("ctrl+right", "cursor_word_right", e => {
    Autocomplete.moveCursorWordRight(e.target);
    e.preventDefault();
  }, $fields_multiple);

  Utility.keydown("ctrl+shift+left", "selection_word_left", e => {
    Autocomplete.moveSelectionWordLeft(e.target);
    e.preventDefault();
  }, $fields_multiple);

  Utility.keydown("ctrl+shift+right", "selection_word_right", e => {
    Autocomplete.moveSelectionWordRight(e.target);
    e.preventDefault();
  }, $fields_multiple);

  $fields_multiple.on("selectionchange", function(e) {
    var $input = $(this);
    var autocomplete = $input.autocomplete("instance");
    var $autocomplete_menu = autocomplete.menu.element;

    // Close the autocomplete menu if the cursor is moved to a different tag (from the Nth term to the Mth term).
    let currentTerm = this.value.substring(0, this.selectionStart).split(/\s+/).length;
    if ($autocomplete_menu.is(":visible") && currentTerm !== autocomplete.previousTerm) {
      autocomplete.close();
    }

    autocomplete.previousTerm = currentTerm;
  });
}

Autocomplete.current_term = function($input, caret = $input.get(0).selectionStart) {
  let query = $input.get(0).value;
  let term_before_caret = query.substring(0, caret);
  let term_after_caret = query.substring(caret).match(/\S*/)[0];
  let term = term_before_caret;
  if (term_after_caret) {
    // If the caret is in the middle of tag, treat it as a wildcard asterisk.
    // This allows the user to get useful autocomplete results by only typing the first few characters of a word between two other words.
    term += "*" + term_after_caret;
    if (!term_before_caret.includes("*") && !term_after_caret.includes("*")) {
      // If the user did not manually type an asterisk then we need to add one at the end to simulate the normal prefix search behavior.
      term += "*";
    }
  }
  let regexp = new RegExp(`^[-~(]*(${Autocomplete.tag_prefixes().join("|")})?`);
  let match = term.match(/\S*$/)[0].replace(regexp, "").toLowerCase();
  return match;
};

// Update the input field with the item currently focused in the
// autocomplete menu, then position the caret just after the inserted completion.
Autocomplete.insert_completion = function(input, completion) {
  let caret = input.selectionStart;
  let term_after_caret = input.value.substring(caret).match(/\S*/)[0];
  caret += term_after_caret.length;

  // Trim all whitespace (tabs, spaces) except for line returns
  var before_caret_text = input.value.substring(0, caret).replace(/^[ \t]+|[ \t]+$/gm, "");
  var after_caret_text = input.value.substring(caret).replace(/^[ \t]+|[ \t]+$/gm, "");

  var regexp = new RegExp(`([-~(]*(?:${Autocomplete.tag_prefixes().join("|")})?)\\S+$`, "g");
  before_caret_text = before_caret_text.replace(regexp, "$1") + completion + " ";
  if (after_caret_text.length > 0) {
    after_caret_text = " " + after_caret_text;
  }

  $(input).replaceFieldText(before_caret_text + after_caret_text);
  input.selectionStart = input.selectionEnd = before_caret_text.length;

  $(input).trigger("input"); // Manually trigger an input event because programmatically editing the field won't trigger one.
  $(() => $(input).autocomplete("instance").close()); // XXX Hack to close the autocomplete menu after the input event above retriggers it
};

Autocomplete.moveCursorWordLeft = function (target) {
  let selected = target.selectionStart !== target.selectionEnd;
  if (selected) {
    target.selectionEnd = target.selectionStart;
    return;
  }

  let caret = target.selectionStart;
  var before_caret_text = target.value.substring(0, caret);
  let match = before_caret_text.match(Autocomplete.PREV_WORD_REGEXP);

  if (match) {
    target.selectionStart = target.selectionEnd = match.index;
    Autocomplete.scrollCursorIntoView(target, "backward");
  }
}

Autocomplete.moveCursorWordRight = function (target) {
  let selected = target.selectionStart !== target.selectionEnd;
  if (selected) {
    target.selectionStart = target.selectionEnd;
    return;
  }

  let caret = target.selectionStart;
  var before_caret_text = target.value.substring(0, caret);
  var after_caret_text = target.value.substring(caret);
  let match = after_caret_text.match(Autocomplete.NEXT_WORD_REGEXP);

  if (match) {
    target.selectionStart = target.selectionEnd = before_caret_text.length + match[0].length;
    Autocomplete.scrollCursorIntoView(target, "forward");
  }
}

Autocomplete.moveSelectionWordLeft = function (target) {
  let direction = (target.selectionStart === target.selectionEnd) ? "backward" : target.selectionDirection;
  let caret = (direction === "backward") ? target.selectionStart : target.selectionEnd;
  let match = target.value.substring(0, caret).match(Autocomplete.PREV_WORD_REGEXP);
  let selectionLength = match?.[0]?.length ?? 0;

  if (direction === "backward") {
    target.selectionStart -= selectionLength;
  } else {
    direction = (caret - selectionLength < target.selectionStart) ? "backward" : direction;
    target.selectionEnd = clamp(caret - selectionLength, target.selectionStart, target.value.length);
    target.selectionStart = clamp(caret - selectionLength, 0, target.selectionStart);
  }

  target.selectionDirection = direction;
  Autocomplete.scrollCursorIntoView(target, direction);
}

Autocomplete.moveSelectionWordRight = function (target) {
  let direction = (target.selectionStart === target.selectionEnd) ? "forward" : target.selectionDirection;
  let caret = (direction === "backward") ? target.selectionStart : target.selectionEnd;
  let match = target.value.substring(caret).match(Autocomplete.NEXT_WORD_REGEXP);
  let selectionLength = match?.[0]?.length ?? 0;

  if (direction === "forward") {
    target.selectionEnd += selectionLength;
  } else {
    direction = (caret + selectionLength > target.selectionEnd) ? "forward" : direction;
    target.selectionStart = clamp(caret + selectionLength, 0, target.selectionEnd);
    target.selectionEnd = clamp(caret + selectionLength, target.selectionEnd, target.value.length);
  }

  target.selectionDirection = direction;
  Autocomplete.scrollCursorIntoView(target, direction);
}

// Scroll the input field so that the cursor is visible.
// @param direction {String} - The direction the cursor is moving ("backward" or "forward").
Autocomplete.scrollCursorIntoView = function (input, direction = "backward") {
  let caret = (direction === "backward") ? input.selectionStart : input.selectionEnd;
  let selectionStart = input.selectionStart;
  let selectionEnd = input.selectionEnd;
  let selectionDirection = input.selectionDirection;

  input.setSelectionRange(caret, caret);
  input.blur();
  input.focus();
  input.setSelectionRange(selectionStart, selectionEnd, selectionDirection);
}

// If we press tab while the autocomplete menu is open but nothing is
// focused, complete the first item and close the menu.
Autocomplete.on_tab = function(event) {
  var input = this;
  var autocomplete = $(input).autocomplete("instance");
  var $autocomplete_menu = autocomplete.menu.element;

  if (!$autocomplete_menu.is(":visible")) {
    return;
  }

  if ($autocomplete_menu.has(".ui-state-active").length === 0) {
    autocomplete.menu.next();
    autocomplete.menu.select();
    autocomplete.close();
  }

  // Prevent the tab key from moving focus to the next element.
  event.preventDefault();
};

Autocomplete.render_item = function(list, item) {
  item.html.data("ui-autocomplete-item", item);
  return list.append(item.html);
};

Autocomplete.autocomplete_source = async function (query, type, { allowEmpty = false, limit = Autocomplete.MAX_RESULTS } = {}) {
  if (query === "" && !allowEmpty) {
    return [];
  }

  let html = await $.get("/autocomplete", {
    "search[query]": query,
    "search[type]": type,
    "version": Autocomplete.VERSION,
    "limit": limit,
  });

  let items = $(html).find("li").toArray().map(item => {
    let $item = $(item);
    return { value: $item.attr("data-autocomplete-value"), html: $item };
  });

  return items;
}

Autocomplete.tag_prefixes = function() {
  return JSON.parse($("meta[name=autocomplete-tag-prefixes]").attr("content"));
};

$(document).ready(function() {
  Autocomplete.initialize_all();
});

export default Autocomplete;
