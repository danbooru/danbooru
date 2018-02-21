(function() {
  Danbooru.WikiPage = {};

  Danbooru.WikiPage.initialize_all = function() {
    if ($("#c-wiki-pages,#c-wiki-page-versions").length) {
      this.initialize_shortcuts();
    }
  }

  Danbooru.WikiPage.initialize_shortcuts = function() {
    if ($("#a-show").length) {
      Danbooru.keydown("e", "edit", function(e) {
        $("#wiki-page-edit a")[0].click();
      });

      Danbooru.keydown("shift+d", "delete", function(e) {
        $("#wiki-page-delete a")[0].click();
      });
    }
  }
})();

$(document).ready(function() {
  Danbooru.WikiPage.initialize_all();
});
