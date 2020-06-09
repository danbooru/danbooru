require 'test_helper'

class UploadsControllerTest < ActionDispatch::IntegrationTest
  def assert_uploaded(file_path, user, **upload_params)
    file = Rack::Test::UploadedFile.new("#{Rails.root}/#{file_path}")

    assert_difference(["Upload.count", "Post.count"]) do
      post_auth uploads_path, user, params: { upload: { file: file, **upload_params }}
      assert_redirected_to Upload.last
    end

    Upload.last
  end

  context "The uploads controller" do
    setup do
      @user = create(:contributor_user)
      mock_iqdb_service!
    end

    context "batch action" do
      context "for twitter galleries" do
        should "render" do
          skip "Twitter keys are not set" unless Danbooru.config.twitter_api_key
          get_auth batch_uploads_path, @user, params: {:url => "https://twitter.com/lvlln/status/567054278486151168"}
          assert_response :success
        end
      end

      context "for pixiv ugoira galleries" do
        should "render" do
          get_auth batch_uploads_path, @user, params: {:url => "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=59523577"}
          assert_response :success
          assert_no_match(/59523577_ugoira0\.jpg/, response.body)
        end
      end

      context "for a blank source" do
        should "render" do
          get_auth batch_uploads_path, @user
          assert_response :success
        end
      end
    end

    context "preprocess action" do
      should "prefer the file over the source when preprocessing" do
        file = Rack::Test::UploadedFile.new("#{Rails.root}/test/files/test.jpg", "image/jpeg")
        post_auth preprocess_uploads_path, @user, params: {:upload => {:source => "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg", :file => file}}
        assert_response :success
        perform_enqueued_jobs
        assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", Upload.last.md5)
      end
    end

    context "new action" do
      should "render" do
        get_auth new_upload_path, @user
        assert_response :success
      end

      context "with a url" do
        should "preprocess" do
          assert_difference(-> { Upload.count }) do
            get_auth new_upload_path, @user, params: {:url => "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"}
            perform_enqueued_jobs
            assert_response :success
          end
        end

        should "prefer the file" do
          get_auth new_upload_path, @user, params: {url: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"}
          perform_enqueued_jobs
          file = Rack::Test::UploadedFile.new("#{Rails.root}/test/files/test.jpg", "image/jpeg")
          assert_difference(-> { Post.count }) do
            post_auth uploads_path, @user, params: {upload: {file: file, tag_string: "aaa", rating: "q", source: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"}}
          end
          post = Post.last
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", post.md5)
        end
      end

      context "for a direct link twitter post" do
        setup do
          @ref = "https://twitter.com/onsen_musume_jp/status/865534101918330881"
          @source = "https://pbs.twimg.com/media/DAL-ntWV0AEbhes.jpg:orig"
        end

        should "trigger the preprocessor" do
          assert_difference(-> { Upload.preprocessed.count }, 1) do
            get_auth new_upload_path, @user, params: {:url => @source, :ref => @ref}
            perform_enqueued_jobs
          end
        end
      end

      context "for a twitter post" do
        setup do
          @source = "https://twitter.com/onsen_musume_jp/status/865534101918330881"
        end

        should "render" do
          skip "Twitter keys are not set" unless Danbooru.config.twitter_api_key
          get_auth new_upload_path, @user, params: {:url => @source}
          assert_response :success
        end

        should "set the correct source" do
          skip "Twitter keys are not set" unless Danbooru.config.twitter_api_key
          get_auth new_upload_path, @user, params: {:url => @source}
          assert_response :success
          perform_enqueued_jobs
          upload = Upload.last
          assert_equal(@source, upload.source)
        end
      end

      context "for a pixiv post" do
        setup do
          @ref = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=49270482"
          @source = "https://i.pximg.net/img-original/img/2015/03/14/17/53/32/49270482_p0.jpg"
        end

        should "trigger the preprocessor" do
          assert_difference(-> { Upload.preprocessed.count }, 1) do
            get_auth new_upload_path, @user, params: {:url => @source, :ref => @ref}
            perform_enqueued_jobs
          end
        end
      end

      context "for a post that has already been uploaded" do
        setup do
          as_user do
            @post = create(:post, :source => "http://google.com/aaa")
          end
        end

        should "initialize the post" do
          assert_difference(-> { Upload.count }, 0) do
            get_auth new_upload_path, @user, params: {:url => "http://google.com/aaa"}
            assert_response :success
          end
        end
      end
    end

    context "index action" do
      setup do
        as_user do
          @upload = create(:source_upload, tag_string: "foo bar")
          @upload2 = create(:source_upload, tag_string: "tagme", rating: "e")
        end
      end

      should "render" do
        get uploads_path
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          search_params = {
            uploader_name: @upload.uploader.name,
            source_matches: @upload.source,
            rating: @upload.rating,
            status: @upload.status,
            server: @upload.server
          }

          get_auth uploads_path, @user, params: { search: search_params }
          assert_response :success

          get_auth uploads_path(format: :json), @user, params: { search: search_params }
          assert_response :success
          assert_equal(@upload.id, response.parsed_body.first["id"])
        end
      end
    end

    context "show action" do
      setup do
        as_user do
          @upload = create(:jpg_upload)
        end
      end

      should "render" do
        get_auth upload_path(@upload), @user
        assert_response :success
      end
    end

    context "create action" do
      context "when a preprocessed upload already exists" do
        context "for twitter" do
          setup do
            as_user do
              @ref = "https://twitter.com/onsen_musume_jp/status/865534101918330881"
              @source = "https://pbs.twimg.com/media/DAL-ntWV0AEbhes.jpg:orig"
              @upload = create(:upload, status: "preprocessed", source: @source, referer_url: @ref, image_width: 0, image_height: 0, file_size: 0, md5: "something", file_ext: "jpg")
            end
          end

          should "update the predecessor" do
            assert_difference(-> { Post.count }, 1) do
              assert_difference(-> { Upload.count }, 0) do
                post_auth uploads_path, @user, params: {:upload => {:tag_string => "aaa", :rating => "q", :source => @source, :referer_url => @ref}}
              end
            end
            post = Post.last
            assert_match(/aaa/, post.tag_string)
          end
        end

        context "for pixiv" do
          setup do
            @ref = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=49270482"
            @source = "https://i.pximg.net/img-original/img/2015/03/14/17/53/32/49270482_p0.jpg"
            as_user do
              @upload = create(:upload, status: "preprocessed", source: @source, referer_url: @ref, image_width: 0, image_height: 0, file_size: 0, md5: "something", file_ext: "jpg")
            end
          end

          should "update the predecessor" do
            assert_difference(-> { Post.count }, 1) do
              assert_difference(-> { Upload.count }, 0) do
                post_auth uploads_path, @user, params: {:upload => {:tag_string => "aaa", :rating => "q", :source => @source, :referer_url => @ref}}
              end
            end
            post = Post.last
            assert_match(/aaa/, post.tag_string)
          end
        end
      end

      context "when the uploader is limited" do
        should "not allow uploading" do
          @member = create(:user, created_at: 2.weeks.ago, upload_points: 0)
          create_list(:post, @member.upload_limit.upload_slots, uploader: @member, is_pending: true)

          assert_no_difference("Post.count") do
            file = Rack::Test::UploadedFile.new("#{Rails.root}/test/files/test.jpg", "image/jpeg")
            post_auth uploads_path, @member, params: { upload: { file: file, tag_string: "aaa", rating: "q" }}
          end

          @upload = Upload.last
          assert_redirected_to @upload
          assert_match(/have reached your upload limit/, @upload.status)
        end
      end

      context "for a 2+ minute long video" do
        should "allow the upload if the user is an admin" do
          @source = "https://twitter.com/7u_NABY/status/1269599527700295681"
          post_auth uploads_path, create(:admin_user, created_at: 1.week.ago), params: { upload: { tag_string: "aaa", rating: "q", source: @source }}
          assert_redirected_to Upload.last

          assert_equal("mp4", Upload.last.file_ext)
          assert_equal("completed", Upload.last.status)
          assert_equal(1280, Upload.last.image_width)
          assert_equal(720, Upload.last.image_height)
          assert_equal("mp4", Upload.last.post.file_ext)
        end
      end

      context "uploading a file from your computer" do
        should "work for a jpeg file" do
          upload = assert_uploaded("test/files/test.jpg", @user, tag_string: "aaa", rating: "e", source: "aaa")

          assert_equal("jpg", upload.post.file_ext)
          assert_equal("aaa", upload.post.source)
          assert_equal(500, upload.post.image_width)
          assert_equal(335, upload.post.image_height)
        end

        should "work for a webm file" do
          upload = assert_uploaded("test/files/test-512x512.webm", @user, tag_string: "aaa", rating: "e", source: "aaa")

          assert_equal("webm", upload.post.file_ext)
          assert_equal("aaa", upload.post.source)
          assert_equal(512, upload.post.image_width)
          assert_equal(512, upload.post.image_height)
        end

        should "work for a flash file" do
          upload = assert_uploaded("test/files/compressed.swf", @user, tag_string: "aaa", rating: "e", source: "aaa")

          assert_equal("swf", upload.post.file_ext)
          assert_equal("aaa", upload.post.source)
          assert_equal(607, upload.post.image_width)
          assert_equal(756, upload.post.image_height)
        end
      end
    end
  end
end
