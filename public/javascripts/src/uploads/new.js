$(document).ready(function() {
	var img = $("#image-preview img");
	if (img) {
		var height = img.attr("height");
		var width = img.attr("width");
		if (height > 400) {
			var ratio = 400.0 / height;
			img.attr("height", height * ratio);
			img.attr("width", width * ratio);
			$("#scale").val("Scaled " + parseInt(100 * ratio) + "%");
		}
	}
});
