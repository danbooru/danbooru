(function() {
  Danbooru.Upload = {};
  
  Danbooru.Upload.initialize_all = function() {
    this.initialize_image();
    this.initialize_info();
  }
  
  Danbooru.Upload.initialize_info = function() {
    $("#c-uploads #source-info ul").hide();
    $("#c-uploads #fetch-data").click(function(e) {
      Danbooru.ajax_start(e.target);
      $.get(e.target.href).success(function(data) {
        var artist_name = data.artist_name;
        var profile_url = data.profile_url;
        var tags = data.tags;
        var danbooru_id = data.danbooru_id;
        var danbooru_name = data.danbooru_name;
        var tag_html = "";
        $.each(data.tags, function(i, v) {
          var name = v[0];
          var url = v[1];
          tag_html += ('<a href="' + url + '">' + name + '</a> ');
        });
        
        $("#source-artist").html('<a href="' + data.profile_url + '">' + data.artist_name + '</a>');
        $("#source-tags").html(tag_html);
        
        var new_artist_link = '<a href="/artists/new?name=' + data.unique_id + '&other_names=' + data.artist_name + '&urls=' + encodeURIComponent(profile_url) + '+' + encodeURIComponent($("#image").attr("src")) + '">new</a>';

        if (data.danbooru_id) {
          $("#source-record").html('<a href="/artists/' + data.danbooru_id + '">' + data.danbooru_name + '</a> ' + new_artist_link);
        } else {
          $("#source-record").html(new_artist_link);
        }
        
        $("#source-info p").hide();
        $("#source-info ul").show();
      }).complete(function(data) {
        Danbooru.ajax_stop(e.target);
      });
      e.preventDefault();
    });
  }
  
  Danbooru.Upload.initialize_image = function() {
    var $image = $("#c-uploads #image");
    if ($image.size() > 0) {
      var height = $image.height();
      var width = $image.width();
      if (height > 400) {
        var ratio = 400.0 / height;
        $image.height(height * ratio);
        $image.width(width * ratio);
        $("#scale").html("Scaled " + parseInt(100 * ratio) + "%");
      }
    }
  }
})();

$(function() {
  Danbooru.Upload.initialize_all();
});
