Cookie.setup();

$(document).ready(function() {
	$("#hide-upgrade-account-link").click(function() {
		$("#upgrade-account").hide();
		Cookie.put('hide-upgrade-account', '1', 7);
	});
});
