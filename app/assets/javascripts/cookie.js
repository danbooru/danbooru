(function() {
  Danbooru.Cookie = {};
  
  Danbooru.Cookie.put = function(name, value, days) {
    if (days == null) {
      days = 365;
    }

    var date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    var expires = "; expires=" + date.toGMTString();
    document.cookie = name + "=" + encodeURIComponent(value) + expires + "; path=/";
  }
  
  Danbooru.Cookie.raw_get = function(name) {
    var nameEq = name + "=";
    var ca = document.cookie.split(";");

    for (var i = 0; i < ca.length; ++i) {
      var c = ca[i];

      while (c.charAt(0) == " ") {
        c = c.substring(1, c.length);
      }

      if (c.indexOf(nameEq) == 0) {
        return c.substring(nameEq.length, c.length);
      }
    }

    return "";
  }
  
  Danbooru.Cookie.get = function(name) {
    return this.unescape(this.raw_get(name));
  }
  
  Danbooru.Cookie.remove = function(name) {
    this.put(name, "", -1);
  }

  Danbooru.Cookie.unescape = function(val) {
    return decodeURIComponent(val.replace(/\+/g, " "));
  }

  Danbooru.Cookie.initialize = function() {
    var loc = location.href;
    
    if (loc.match(/^http/)) {
      loc = loc.replace(/^https?:\/\/[^\/]+/, "")
    }
    
    if (loc.match(/^\/(comment|pool|note|post)/) && this.get("tos") != "1") {
      // Setting location.pathname in Safari doesn't work, so manually extract the domain.
      var domain = location.href.match(/^(https?:\/\/[^\/]+)/)[0];
      location.href = domain + "/terms_of_service?url=" + encodeURIComponent(location.href);
      return;
    }

		if (this.get("hide-upgrade-account") != "1") {
 	    $("#upgrade-account").show();
		}
  }
})();

$(function() {
  Danbooru.Cookie.initialize();
});

