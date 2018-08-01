import Utility from './utility'

let WikiPage = {};

WikiPage.initialize_all = function() {
  if ($("#c-wiki-pages,#c-wiki-page-versions").length) {
    this.initialize_shortcuts();
  }
}

WikiPage.initialize_shortcuts = function() {
  if ($("#a-show").length) {
    Utility.keydown("e", "edit", function(e) {
      $("#wiki-page-edit a")[0].click();
    });

    Utility.keydown("shift+d", "delete", function(e) {
      $("#wiki-page-delete a")[0].click();
    });
  }
}

$(document).ready(function() {
  WikiPage.initialize_all();
});
