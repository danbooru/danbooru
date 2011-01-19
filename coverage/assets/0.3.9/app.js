$(document).ready(function() {
  $('.file_list').dataTable({
    "aaSorting": [[ 1, "asc" ]],
    "bPaginate": false,
    "bJQueryUI": true,
    "aoColumns": [
			null,
		  { "sType": "percent" },
			null,
			null,
			null,
			null
		]
  });
  
  $('.source_table tbody tr:odd').addClass('odd');
  $('.source_table tbody tr:even').addClass('even');
  
  $("a.src_link").fancybox({
		'hideOnContentClick': true
	});
	
	// Hide src files and file list container
  $('.source_files').hide();
  $('.file_list_container').hide();
  
  // Add tabs based upon existing file_list_containers
  $('.file_list_container h2').each(function(){
    $('.group_tabs').append('<li><a href="#' + $(this).parent().attr('id') + '">' + $(this).html() + '</a></li>');
  });

  $('.group_tabs a').each( function() {
    $(this).addClass($(this).attr('href').replace('#', ''));
  });
  
  $('.group_tabs a').live('focus', function() {
    $(this).blur();
  });
  
  var favicon_path = $('link[rel="shortcut icon"]').attr('href')
  $('.group_tabs a').live('click', function(){
    if (!$(this).parent().hasClass('active')) {
      $('.group_tabs a').parent().removeClass('active');
      $(this).parent().addClass('active');
      $('.file_list_container').hide();
      $(".file_list_container" + $(this).attr('href')).show();
      window.location.href = window.location.href.split('#')[0] + $(this).attr('href').replace('#', '#_');
      
      // Force favicon reload - otherwise the location change containing anchor would drop the favicon...
      // Works only on firefox, but still... - Anyone know a better solution to force favicon?
      $('link[rel="shortcut icon"]').remove();
      $('head').append('<link rel="shortcut icon" type="image/png" href="'+ favicon_path +'" />');
    };
    return false;
  });
  
  if (jQuery.url.attr('anchor')) {
    $('.group_tabs a.'+jQuery.url.attr('anchor').replace('_', '')).click();
  } else {
    $('.group_tabs a:first').click();
  };
  
  $("abbr.timeago").timeago();
  $('#loading').fadeOut();
  $('#wrapper').show();
});
