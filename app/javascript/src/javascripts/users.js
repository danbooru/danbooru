let User = {};

User.initialize_all = function() {
  $(document).on("click.danbooru", "#c-users #a-edit #edit-options a", User.toggle_edit_tab);
}

User.toggle_edit_tab = function(e) {
  let $target = $(e.target);
  $("h2 a").removeClass("active");
  $("#basic-settings-section,#advanced-settings-section").hide();
  $target.addClass("active")
  $($target.attr("href") + "-section").show();
  e.preventDefault();
};

$(User.initialize_all);

export default User
