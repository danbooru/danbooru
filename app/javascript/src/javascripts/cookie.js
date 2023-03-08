let Cookie = {};

Cookie.put = function(name, value, max_age_in_seconds = 60 * 60 * 24 * 365 * 20) {
  let cookie = `${name}=${encodeURIComponent(value)}; Path=/; SameSite=Lax;`;

  if (max_age_in_seconds) {
    cookie += ` Max-Age=${max_age_in_seconds};`
  }

  if (location.protocol === "https:") {
    cookie += " Secure;";
  }

  document.cookie = cookie;
}

Cookie.get = function(name) {
  var nameEq = name + "=";
  var ca = document.cookie.split(";");

  for (var i = 0; i < ca.length; ++i) {
    var c = ca[i];

    while (c.charAt(0) === " ") {
      c = c.substring(1, c.length);
    }

    if (c.indexOf(nameEq) === 0) {
      return this.unescape(c.substring(nameEq.length, c.length));
    }
  }

  return null;
}

Cookie.remove = function(name) {
  this.put(name, "", -1);
}

Cookie.unescape = function(val) {
  return decodeURIComponent(val.replace(/\+/g, " "));
}

Cookie.getItem = Cookie.get;
Cookie.setItem = Cookie.put;

Cookie.initialize = function() {
  if (this.get("hide-upgrade-account") !== "1") {
    $("#upgrade-account").show();
  }
}

$(function() {
  Cookie.initialize();
});

export default Cookie
