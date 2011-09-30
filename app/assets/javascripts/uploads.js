(function() {
  Danbooru.Upload = {};
  
  Danbooru.Upload.initialize_all = function() {
    this.initialize_image();
    this.initialize_info();
    this.initialize_similar();
  }

  Danbooru.Upload.initialize_similar = function() {
    $("#similar-button").click(function(e) {
      var old_source_name = $("#upload_source").attr("name");
  		var old_file_name = $("#upload_file").attr("name")
  		var old_target = $("#form").attr("target");
  		var old_action = $("#form").attr("action");

  		$("#upload_source").attr("name", "url");
  		$("#upload_file").attr("name", "file");
  		$("#form").attr("target", "_blank");
  		$("#form").attr("action", "http://danbooru.iqdb.hanyuu.net/");

  		$("form").trigger("submit");

  		$("#upload_source").attr("name", old_source_name);
  		$("#upload_file").attr("name", old_file_name);
  		$("#form").attr("target", old_target);
  		$("#form").attr("action", old_action);
  		
  		e.preventDefault();
    });
  }
  
  Danbooru.Upload.initialize_info = function() {
    $("#c-uploads #source-info ul").hide();
    $("#c-uploads #fetch-data").click(function(e) {
      Danbooru.ajax_start(e.target);
      $.get(e.target.href).success(function(data) {
        var tag_html = "";
        $.each(data.tags, function(i, v) {
          tag_html += ('<a href="' + v[1] + '">' + v[0] + '</a> ');
        });
        
        $("#source-artist").html('<a href="' + data.profile_url + '">' + data.artist_name + '</a>');
        $("#source-tags").html(tag_html);
        
        var new_artist_link = '<a href="/artists/new?name=' + data.unique_id + '&other_names=' + data.artist_name + '&urls=' + encodeURIComponent(data.profile_url) + '+' + encodeURIComponent(data.image_url) + '">new</a>';

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
