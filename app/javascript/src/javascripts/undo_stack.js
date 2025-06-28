import Utility from './utility';
import { isBeforeInputEventAvailable }  from './utility'

class UndoItem {
  constructor(element, action) {
    this.value = element.value;
    this.selectionStart = element.selectionStart;
    this.selectionEnd = element.selectionEnd;
    this.action = action;
  };

  apply(element) {
    element.value = this.value;
    element.selectionStart = this.selectionStart;
    element.selectionEnd = this.selectionEnd;
  }
};

class UndoStack {
  constructor(element) {
    this.element = element;
    element.undoStack = this;
    this.undoItems = [];
    this.redoItems = [];
    this.currentItem = new UndoItem(this.element, null);
  };

  undo() {
    this.updateCurrent();
    while (this.undoItems.length > 0) {
      let item = this.undoItems.pop();
      if (item.value == this.currentItem.value) {
        continue;
      }
      this.redoItems.push(this.currentItem);
      this.currentItem = item;
      this.currentItem.apply(this.element);
      break;
    }
  }

  redo() {
    if (this.redoItems.length > 0) {
      this.undoItems.push(this.currentItem);
      let item = this.redoItems.pop();
      this.currentItem = item;
      this.currentItem.apply(this.element);
    }
  }

  updateCurrent() {
    this.currentItem = new UndoItem(this.element, null);
  }

  save(action, force = false) {
    if (!force) {
      if (this.undoItems.length > 0) {
        let last_item = this.undoItems[this.undoItems.length - 1];
        if (this.element.value === last_item.value) {
          return;
        } else if (action === last_item.action) {
          return;
        }
      }
    }
    let item = new UndoItem(this.element, action);
    this.undoItems.push(item);
    this.redoItems = [];
  }

  static initialize_fields($fields) {
    if (!isBeforeInputEventAvailable()) {
      // This undo implementation will not work if the "beforeinput" event is not supported.
      // Disable this implementation and use the browser's native undo instead.
      return;
    };

    $fields.each((_, element) => {
      new UndoStack(element);
    })

    $fields.on("beforeinput", function(e) {
      if (!e || !e.originalEvent) {
        return;
      }
      let target = e.target;
      let event = e.originalEvent;

      if (event.inputType == "historyUndo") {
        target.undoStack.undo();
        e.preventDefault();
      } else if (event.inputType == "historyRedo") {
        target.undoStack.redo();
        e.preventDefault();
      } else {
        target.undoStack.save(event.inputType);
      }
    });

    $fields.on("input", function(e) {
      if (!e) {
        return;
      }
      e.target.undoStack.updateCurrent();
    });

    Utility.keydown("ctrl+z", "undo", e => {
      let target = e.target;
      target.undoStack.undo();
      e.preventDefault();
    }, $fields);

    Utility.keydown("ctrl+shift+z", "redo", e => {
      let target = e.target;
      target.undoStack.redo();
      e.preventDefault();
    }, $fields);
  }
};

export default UndoStack;
