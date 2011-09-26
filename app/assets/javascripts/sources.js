(function() {
  Danbooru.Sources = {};
  
  Danbooru.Sources.get = function(url) {
    $.get("/sources.json", {
      url: url
    }).success(function(data) {
      console.log(data);
    }).error(function(data) {
      console.log(data);
    });
  }
})();

