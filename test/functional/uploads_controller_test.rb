require 'test_helper'

class UploadsControllerTest < ActionDispatch::IntegrationTest
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
        post_auth preprocess_uploads_path, @user, params: {:upload => {:source => "https://raikou1.donmai.us/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg", :file => file}}
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
            get_auth new_upload_path, @user, params: {:url => "https://raikou1.donmai.us/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"}
            perform_enqueued_jobs
            assert_response :success
          end
        end

        should "prefer the file" do
          get_auth new_upload_path, @user, params: {url: "https://raikou1.donmai.us/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"}
          perform_enqueued_jobs
          file = Rack::Test::UploadedFile.new("#{Rails.root}/test/files/test.jpg", "image/jpeg")
          assert_difference(-> { Post.count }) do
            post_auth uploads_path, @user, params: {upload: {file: file, tag_string: "aaa", rating: "q", source: "https://raikou1.donmai.us/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"}}
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
            server: @upload.server,
          }

          get uploads_path, params: { search: search_params }
          assert_response :success

          get uploads_path(format: :json), params: { search: search_params }
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
            assert_difference(->{ Post.count }, 1) do
              assert_difference(->{ Upload.count }, 0) do
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
            assert_difference(->{ Post.count }, 1) do
              assert_difference(->{ Upload.count }, 0) do
                post_auth uploads_path, @user, params: {:upload => {:tag_string => "aaa", :rating => "q", :source => @source, :referer_url => @ref}}
              end
            end
            post = Post.last
            assert_match(/aaa/, post.tag_string)            
          end
        end
      end

      should "create a new upload" do
        assert_difference("Upload.count", 1) do
          file = Rack::Test::UploadedFile.new("#{Rails.root}/test/files/test.jpg", "image/jpeg")
          post_auth uploads_path, @user, params: {:upload => {:file => file, :tag_string => "aaa", :rating => "q", :source => "aaa"}}
        end
      end
    end
  end
end
