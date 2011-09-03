//= require jquery-1.6.2.min.js
//= require jquery-ui-1.8.12.custom.min.js
//= require keymaster.min.js
//= require jquery.hotkeys.js
//= require jquery.timeout.js
//= require rails.js
//= require common.js
//= require_self
//= require_tree .

(function() {
  Danbooru.Paginator = {};
  Danbooru.Paginator.next_page = function() {
    if($('.paginator li span').parent().next().length != 0)
    {
      window.location = $('.paginator li span').parent().next().find('a').attr('href');
    }
  }

  Danbooru.Paginator.prev_page = function() {
    if($('.paginator li span').parent().prev().length != 0)
    {
      window.location = $('.paginator li span').parent().prev().find('a').attr('href');
      console.log('logged')
    }
  }
})();
