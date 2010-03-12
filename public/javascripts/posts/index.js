function submit_quick_edit(e) {
  e.stopPropagation();
  $("#quick-edit").hide();
	$.post("/posts.js", $("#quick-edit form").serialize());
}

$(document).ready(function() {
	$("#quick-edit form").submit(submit_quick_edit);
	$("#post_tag_string").keydown(function(e) {
	  if (e.keyCode != 13)
	    return;
	  submit_quick_edit(e);
	  e.stopPropagation();
	})
	$("#mode-box select").click()
	PostModeMenu.init();
});
