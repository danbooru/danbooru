(function() {
  Danbooru.Paginator = {};
  
  Danbooru.Paginator.next_page = function() {
    if ($('.paginator li span').parent().next().length) {
      window.location = $('.paginator li span').parent().next().find('a').attr('href');
    }
  }

  Danbooru.Paginator.prev_page = function() {
    if ($('.paginator li span').parent().prev().length) {
      window.location = $('.paginator li span').parent().prev().find('a').attr('href');
    }
  }
})();

$(function() {
  key('right', function(){ Danbooru.Paginator.next_page() });
  key('left', function(){ Danbooru.Paginator.prev_page() });
});

