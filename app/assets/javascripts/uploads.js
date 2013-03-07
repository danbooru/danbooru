(function() {
  Danbooru.Upload = {};
  
  Danbooru.Upload.initialize_all = function() {
    if ($("#c-uploads,#c-posts").length) {
      this.initialize_enter_on_tags();
    }
    
    if ($("#c-uploads").length) {
      this.initialize_image();
      this.initialize_info();
      this.initialize_similar();
    }
  }
  
  Danbooru.Upload.initialize_enter_on_tags = function() {
    $("#upload_tag_string,#post_tag_string").bind("keydown.return", function(e) {
      $("#form").trigger("submit");
      $("#quick-edit-form").trigger("submit");
      e.preventDefault();
    });
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
  		$("#form").attr("action", "http://danbooru.iqdb.org/");

      $("#form").trigger("submit");

  		$("#upload_source").attr("name", old_source_name);
  		$("#upload_file").attr("name", old_file_name);
  		$("#form").attr("target", old_target);
  		$("#form").attr("action", old_action);
  		
  		e.preventDefault();
    });
  }
  
  Danbooru.Upload.initialize_info = function() {
    $("#source-info ul").hide();
    $("#fetch-data").click(function(e) {
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
      });
      e.preventDefault();
    });
  }
  
  Danbooru.Upload.initialize_image = function() {
    var $image = $("#image");
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
