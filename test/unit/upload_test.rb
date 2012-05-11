require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      user = Factory.create(:contributor_user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil

      @upload.delete_temp_file if @upload
    end

    context "An upload" do    
      teardown do
        FileUtils.rm_f(Dir.glob("#{Rails.root}/tmp/test.*"))
      end

      context "image size calculator" do
        should "discover the dimensions for a JPG" do
          @upload = Factory.create(:jpg_upload)
          assert_nothing_raised {@upload.calculate_dimensions(@upload.file_path)}
          assert_equal(500, @upload.image_width)
          assert_equal(335, @upload.image_height)
        end

        should "discover the dimensions for a PNG" do
          @upload = Factory.create(:png_upload)
          assert_nothing_raised {@upload.calculate_dimensions(@upload.file_path)}
          assert_equal(768, @upload.image_width)
          assert_equal(1024, @upload.image_height)
        end

        should "discover the dimensions for a GIF" do
          @upload = Factory.create(:gif_upload)
          assert_nothing_raised {@upload.calculate_dimensions(@upload.file_path)}
          assert_equal(400, @upload.image_width)
          assert_equal(400, @upload.image_height)
        end
      end

      context "content type calculator" do
        should "know how to parse jpeg, png, gif, and swf file extensions" do
          @upload = Factory.create(:jpg_upload)
          assert_equal("image/jpeg", @upload.file_ext_to_content_type("test.jpeg"))
          assert_equal("image/gif", @upload.file_ext_to_content_type("test.gif"))
          assert_equal("image/png", @upload.file_ext_to_content_type("test.png"))
          assert_equal("application/x-shockwave-flash", @upload.file_ext_to_content_type("test.swf"))
          assert_equal("application/octet-stream", @upload.file_ext_to_content_type(""))
        end

        should "know how to parse jpeg, png, gif, and swf content types" do
          @upload = Factory.create(:jpg_upload)
          assert_equal("jpg", @upload.content_type_to_file_ext("image/jpeg"))
          assert_equal("gif", @upload.content_type_to_file_ext("image/gif"))
          assert_equal("png", @upload.content_type_to_file_ext("image/png"))
          assert_equal("swf", @upload.content_type_to_file_ext("application/x-shockwave-flash"))
          assert_equal("bin", @upload.content_type_to_file_ext(""))
        end
      end

      context "downloader" do
        should "initialize the final path and content type after downloading a file" do
          @upload = Factory.create(:source_upload)
          path = "#{Rails.root}/tmp/test.download.jpg"
          assert_nothing_raised {@upload.download_from_source(path)}
          assert(File.exists?(path))
          assert_equal(8558, File.size(path))
          assert_equal("image/gif", @upload.content_type)
          assert_equal(path, @upload.file_path)
          assert_equal("gif", @upload.file_ext)
        end
      end

      context "file processor" do
        should "parse and process a cgi file representation" do
          FileUtils.cp("#{Rails.root}/test/files/test.jpg", "#{Rails.root}/tmp")
          @upload = Upload.new(:file => upload_jpeg("#{Rails.root}/tmp/test.jpg"))
          assert_nothing_raised {@upload.convert_cgi_file}
          assert_equal("image/jpeg", @upload.content_type)
          assert(File.exists?(@upload.file_path))
          assert_equal(28086, File.size(@upload.file_path))
          assert_equal("jpg", @upload.file_ext)
        end
        
        should "process a transparent png" do
          FileUtils.cp("#{Rails.root}/test/files/alpha.png", "#{Rails.root}/tmp")
          @upload = Upload.new(:file => upload_file("#{Rails.root}/tmp/alpha.png", "image/png", "alpha.png"))
          assert_nothing_raised {@upload.convert_cgi_file}
          assert_equal("image/png", @upload.content_type)
          assert(File.exists?(@upload.file_path))
          assert_equal(1136, File.size(@upload.file_path))
          assert_equal("png", @upload.file_ext)
        end
      end

      context "hash calculator" do
        should "caculate the hash" do
          @upload = Factory.create(:jpg_upload)
          @upload.calculate_hash(@upload.file_path)
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @upload.md5)
        end
      end

      context "resizer" do
        teardown do
          FileUtils.rm_f(Dir.glob("#{Rails.root}/public/data/preview/test.*.jpg"))
          FileUtils.rm_f(Dir.glob("#{Rails.root}/public/data/large/test.*.jpg"))
          FileUtils.rm_f(Dir.glob("#{Rails.root}/public/data/original/test.*.jpg"))
        end

        should "generate several resized versions of the image" do
          @upload = Factory.create(:large_jpg_upload)
          @upload.calculate_hash(@upload.file_path)
          @upload.calculate_dimensions(@upload.file_path)
          assert_nothing_raised {@upload.generate_resizes(@upload.file_path)}
          assert(File.exists?(@upload.resized_file_path_for(Danbooru.config.small_image_width)))
          assert_equal(6197, File.size(@upload.resized_file_path_for(Danbooru.config.small_image_width)))
          assert(File.exists?(@upload.resized_file_path_for(Danbooru.config.large_image_width)))
          assert_equal(117877, File.size(@upload.resized_file_path_for(Danbooru.config.large_image_width)))
        end
      end
      
      should "increment the uploaders post_upload_count" do
        @upload = Factory.create(:source_upload)
        assert_difference("CurrentUser.post_upload_count", 1) do
          @upload.process!
          CurrentUser.reload
        end
      end

      should "process completely for a downloaded image" do
        @upload = Factory.create(:source_upload,
          :rating => "s",
          :uploader_ip_addr => "127.0.0.1",
          :tag_string => "hoge foo"
        )
        assert_difference("Post.count") do
          assert_nothing_raised {@upload.process!}
        end

        post = Post.last
        assert_equal("foo hoge", post.tag_string)
        assert_equal("s", post.rating)
        assert_equal(@upload.uploader_id, post.uploader_id)
        assert_equal("127.0.0.1", post.uploader_ip_addr)
        assert_equal(@upload.md5, post.md5)
        assert_equal("gif", post.file_ext)
        assert_equal(276, post.image_width)
        assert_equal(110, post.image_height)
        assert_equal(8558, post.file_size)
        assert_equal(post.id, @upload.post_id)
        assert_equal("completed", @upload.status)
      end
    end

    should "process completely for an uploaded image" do
      @upload = Factory.create(:jpg_upload,
        :rating => "s",
        :uploader_ip_addr => "127.0.0.1",
        :tag_string => "hoge foo"
      )
      @upload.file = upload_jpeg("#{Rails.root}/test/files/test.jpg")
      @upload.convert_cgi_file

      assert_difference("Post.count") do
        assert_nothing_raised {@upload.process!}
      end
      post = Post.last
      assert_equal("foo hoge", post.tag_string)
      assert_equal("s", post.rating)
      assert_equal(@upload.uploader_id, post.uploader_id)
      assert_equal("127.0.0.1", post.uploader_ip_addr)
      assert_equal(@upload.md5, post.md5)
      assert_equal("jpg", post.file_ext)
      assert(File.exists?(post.file_path))
      assert_equal(28086, File.size(post.file_path))
      assert_equal(post.id, @upload.post_id)
      assert_equal("completed", @upload.status)    
    end

    should "delete the temporary file upon completion" do
      @upload = Factory.create(:source_upload,
        :rating => "s",
        :uploader_ip_addr => "127.0.0.1",
        :tag_string => "hoge foo"
      )

      @upload.process!
      assert(!File.exists?(@upload.temp_file_path))
    end
  end
end
