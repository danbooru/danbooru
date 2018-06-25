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
        post_auth preprocess_uploads_path, @user, params: {:url => "http://www.google.com/intl/en_ALL/images/logo.gif", :file => file}
        assert_response :success
        Delayed::Worker.new.work_off
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
            get_auth new_upload_path, @user, params: {:url => "http://www.google.com/intl/en_ALL/images/logo.gif"}
            assert_response :success
          end
        end
      end

      context "for a twitter post" do
        should "render" do
          skip "Twitter keys are not set" unless Danbooru.config.twitter_api_key
          get_auth new_upload_path, @user, params: {:url => "https://twitter.com/frappuccino/status/566030116182949888"}
          assert_response :success
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
        end
      end

      should "render" do
        get uploads_path
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          search_params = {
            uploader_name: @upload.uploader_name,
            source_matches: @upload.source,
            rating: @upload.rating,
            has_post: "yes",
            post_tags_match: @upload.tag_string,
            status: @upload.status,
            server: @upload.server,
          }

          get uploads_path, params: { search: search_params }
          assert_response :success
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
      should "create a new upload" do
        assert_difference("Upload.count", 1) do
          file = Rack::Test::UploadedFile.new("#{Rails.root}/test/files/test.jpg", "image/jpeg")
          post_auth uploads_path, @user, params: {:upload => {:file => file, :tag_string => "aaa", :rating => "q", :source => "aaa"}}
        end
      end
    end
  end
end
