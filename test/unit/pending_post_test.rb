require File.dirname(__FILE__) + '/../test_helper'

class PendingPostTest < ActiveSupport::TestCase
  context "A pending post" do    
    teardown do
      FileUtils.rm_f(Dir.glob("#{Rails.root}/tmp/test.*"))
    end

    context "image size calculator" do
      should "discover the dimensions for a JPG" do
        @pending_post = Factory.create(:uploaded_jpg_pending_post)
        assert_nothing_raised {@pending_post.calculate_dimensions(@pending_post.file_path)}
        assert_equal(500, @pending_post.image_width)
        assert_equal(335, @pending_post.image_height)
      end

      should "discover the dimensions for a PNG" do
        @pending_post = Factory.create(:uploaded_png_pending_post)
        assert_nothing_raised {@pending_post.calculate_dimensions(@pending_post.file_path)}
        assert_equal(768, @pending_post.image_width)
        assert_equal(1024, @pending_post.image_height)
      end

      should "discover the dimensions for a GIF" do
        @pending_post = Factory.create(:uploaded_gif_pending_post)
        assert_nothing_raised {@pending_post.calculate_dimensions(@pending_post.file_path)}
        assert_equal(400, @pending_post.image_width)
        assert_equal(400, @pending_post.image_height)
      end
    end
    
    context "content type calculator" do
      should "know how to parse jpeg, png, gif, and swf file extensions" do
        @pending_post = Factory.create(:uploaded_jpg_pending_post)
        assert_equal("image/jpeg", @pending_post.file_ext_to_content_type("test.jpeg"))
        assert_equal("image/gif", @pending_post.file_ext_to_content_type("test.gif"))
        assert_equal("image/png", @pending_post.file_ext_to_content_type("test.png"))
        assert_equal("application/x-shockwave-flash", @pending_post.file_ext_to_content_type("test.swf"))
        assert_equal("application/octet-stream", @pending_post.file_ext_to_content_type(""))
      end

      should "know how to parse jpeg, png, gif, and swf content types" do
        @pending_post = Factory.create(:uploaded_jpg_pending_post)
        assert_equal("jpg", @pending_post.content_type_to_file_ext("image/jpeg"))
        assert_equal("gif", @pending_post.content_type_to_file_ext("image/gif"))
        assert_equal("png", @pending_post.content_type_to_file_ext("image/png"))
        assert_equal("swf", @pending_post.content_type_to_file_ext("application/x-shockwave-flash"))
        assert_equal("bin", @pending_post.content_type_to_file_ext(""))
      end
    end
    
    context "downloader" do
      should "initialize the final path and content type after downloading a file" do
        @pending_post = Factory.create(:downloadable_pending_post)
        path = "#{Rails.root}/tmp/test.download.jpg"
        assert_nothing_raised {@pending_post.download_from_source(path)}
        assert(File.exists?(path))
        assert_equal(8558, File.size(path))
        assert_equal("image/gif", @pending_post.content_type)
        assert_equal(path, @pending_post.file_path)
        assert_equal("gif", @pending_post.file_ext)
      end
    end
    
    context "file processor" do
      should "parse and process a cgi file representation" do
        FileUtils.cp("#{Rails.root}/test/files/test.jpg", "#{Rails.root}/tmp")
        @pending_post = PendingPost.new(:file => upload_jpeg("#{Rails.root}/tmp/test.jpg"))
        assert_nothing_raised {@pending_post.convert_cgi_file("#{Rails.root}/tmp/test.converted.jpg")}
        assert_equal("image/jpeg", @pending_post.content_type)
        assert_equal("#{Rails.root}/tmp/test.converted.jpg", @pending_post.file_path)
        assert(File.exists?("#{Rails.root}/tmp/test.converted.jpg"))
        assert_equal(28086, File.size("#{Rails.root}/tmp/test.converted.jpg"))
        assert_equal("jpg", @pending_post.file_ext)
      end
    end

    context "hash calculator" do
      should "caculate the hash" do
        @pending_post = Factory.create(:uploaded_jpg_pending_post)
        @pending_post.calculate_hash(@pending_post.file_path)
        assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @pending_post.md5)
      end
    end
    
    context "resizer" do
      teardown do
        FileUtils.rm_f(Dir.glob("#{Rails.root}/public/data/thumb/test.*.jpg"))
        FileUtils.rm_f(Dir.glob("#{Rails.root}/public/data/medium/test.*.jpg"))
        FileUtils.rm_f(Dir.glob("#{Rails.root}/public/data/large/test.*.jpg"))
        FileUtils.rm_f(Dir.glob("#{Rails.root}/public/data/original/test.*.jpg"))
      end
      
      should "generate several resized versions of the image" do
        @pending_post = Factory.create(:uploaded_large_jpg_pending_post)
        @pending_post.calculate_hash(@pending_post.file_path)
        @pending_post.calculate_dimensions(@pending_post.file_path)
        assert_nothing_raised {@pending_post.generate_resizes(@pending_post.file_path)}
        assert(File.exists?(@pending_post.resized_file_path_for(Danbooru.config.small_image_width)))
        assert_equal(6556, File.size(@pending_post.resized_file_path_for(Danbooru.config.small_image_width)))
        assert(File.exists?(@pending_post.resized_file_path_for(Danbooru.config.medium_image_width)))
        assert_equal(39411, File.size(@pending_post.resized_file_path_for(Danbooru.config.medium_image_width)))
        assert(File.exists?(@pending_post.resized_file_path_for(Danbooru.config.large_image_width)))
        assert_equal(179324, File.size(@pending_post.resized_file_path_for(Danbooru.config.large_image_width)))
      end
    end
    
    should "process completely for a downloaded image" do
      @pending_post = Factory.create(:downloadable_pending_post,
        :rating => "s",
        :uploader_ip_addr => "127.0.0.1",
        :tag_string => "hoge foo"
      )
      assert_difference("Post.count") do
        assert_nothing_raised {@pending_post.process!}
      end
      
      post = Post.last
      assert_equal("hoge foo", post.tag_string)
      assert_equal("s", post.rating)
      assert_equal(@pending_post.uploader_id, post.uploader_id)
      assert_equal("127.0.0.1", post.uploader_ip_addr)
      assert_equal(@pending_post.md5, post.md5)
      assert_equal("gif", post.file_ext)
      assert_equal(276, post.image_width)
      assert_equal(110, post.image_height)
      assert_equal(8558, post.file_size)
      assert_equal(post.id, @pending_post.post_id)
      assert_equal("finished", @pending_post.status)
    end
  end
end
