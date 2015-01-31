// Whoever did the rest of js files, he/she did it in some other way
// Hope this is not very wrong
$(document).ready(function() {
  $("#maintoggle").click(function(){
	  $('#nav').toggle();
	  $('#maintoggle').toggleClass('toggler-active');
  });
});
