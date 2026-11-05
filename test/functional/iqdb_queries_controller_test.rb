require "test_helper"

class IqdbQueriesControllerTest < ActionDispatch::IntegrationTest
  context "The iqdb controller" do
    setup do
      @user = create(:user)
      @post = as(@user) { create(:post) }
    end

    context "show action" do
      should "be rate limited" do
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        create(:rate_limit, action: "iqdb_queries:show", key: @user.cache_key, limited: true)

        get_auth iqdb_queries_path, @user, params: { post_id: @post.id }

        assert_response 429
      end

      should "rate limit the create action" do
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        create(:rate_limit, action: "iqdb_queries:create", key: @user.cache_key, limited: true)

        post_auth iqdb_queries_path(format: :json), @user, params: { search: { post_id: @post.id }}

        assert_response 429
      end

      should "not allow anonymous users to search" do
        get iqdb_queries_path, params: { post_id: @post.id }
        assert_response 403
      end

      should "not allow anonymous users to search with the API" do
        post iqdb_queries_path(format: :json), params: { search: { post_id: @post.id }}
        assert_response 403
      end

      should "allow members to view the search page" do
        get_auth iqdb_queries_path, @user
        assert_response :success
      end

      context "with a url parameter" do
        should "use the URL as-is for an image URL" do
          mock_iqdb_matches([{ post_id: @post.id, score: 95.0 }])

          get_auth iqdb_queries_path, @user, as: :javascript, params: { url: "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4" }

          assert_response :success
          assert_select("#post_#{@post.id}")
        end

        context "for a page URL that has a single image" do
          should "download the image from the page" do
            mock_iqdb_matches([{ post_id: @post.id, score: 95.0 }])

            get_auth iqdb_queries_path, @user, as: :javascript, params: { url: "https://bsky.app/profile/ixy.bsky.social/post/3kkvo4d4jd32g" }

            assert_response :success
            assert_select("#post_#{@post.id}")
          end

          should "download the image from the page for a URL without a scheme" do
            mock_iqdb_matches([{ post_id: @post.id, score: 95.0 }])

            get_auth iqdb_queries_path, @user, as: :javascript, params: { url: "bsky.app/profile/ixy.bsky.social/post/3kkvo4d4jd32g" }

            assert_response :success
            assert_select("#post_#{@post.id}")
          end
        end

        should "return an error if the url has multiple images" do
          skip "Twitter credentials not available" unless Source::Extractor::Twitter.enabled?

          mock_iqdb_matches([])
          get_auth iqdb_queries_path, @user, params: { url: "https://twitter.com/fatfatpankocat/status/1763401033680576982" }

          assert_response :success
          assert_select ".post-gallery", /No posts found/
          assert_select "#notice", /.* has multiple images/
        end

        should "return an error if the url doesn't have any images" do
          skip "Twitter credentials not available" unless Source::Extractor::Twitter.enabled?

          mock_iqdb_matches([])
          get_auth iqdb_queries_path, @user, params: { url: "https://twitter.com/dril/status/384408932061417472" }

          assert_response :success
          assert_select ".post-gallery", /No posts found/
          assert_select "#notice", /.* has no images/
        end

        should "return an error if the url points to a prohibited IP" do
          get_auth iqdb_queries_path, @user, as: :javascript, params: { url: "http://0.0.0.0/test.jpg" }

          assert_response :success
          assert_select ".post-gallery", /No posts found/
          assert_select "#notice", /failed with code 591/
        end

        should "return an error if the url is not an image or video" do
          get_auth iqdb_queries_path, @user, as: :javascript, params: { url: "https://example.com" }

          assert_response :success
          assert_select ".post-gallery", /No posts found/
          assert_select "#notice", /File is not an image or video/
        end

        should "return an error if the url without a scheme is not an image or video" do
          get_auth iqdb_queries_path, @user, as: :javascript, params: { url: "example.com" }

          assert_response :success
          assert_select ".post-gallery", /No posts found/
          assert_select "#notice", /File is not an image or video/
        end

        should "return an error if the url is not a valid absolute url" do
          get_auth iqdb_queries_path, @user, as: :javascript, params: { url: "/test.jpg" }

          assert_response :success
          assert_select ".post-gallery", /No posts found/
          assert_select "#notice", /is an invalid URL/
        end
      end

      context "with a post_id parameter" do
        should "render a response" do
          @matches = [{ post_id: @post.id, score: 95.0 }]
          mock_iqdb_matches(@matches)

          # Make the call to `@post.file(:preview)` work.
          Post.any_instance.stubs(:file).returns(File.open("test/files/jpg/test.jpg"))

          get_auth iqdb_queries_path, @user, params: { post_id: @post.id }

          assert_response :success
          assert_select("#post_#{@post.id}")
        end

        should "not search for a post the user can't see" do
          @post.update_columns(is_banned: true) # rubocop:disable Rails/SkipsModelValidations
          IqdbClient.any_instance.expects(:query_file).never

          get_auth iqdb_queries_path, @user, params: { post_id: @post.id }

          assert_response 403
        end
      end

      context "with a media_asset_id parameter" do
        should "not search for a media asset the user can't see" do
          @post.update_columns(is_banned: true) # rubocop:disable Rails/SkipsModelValidations
          IqdbClient.any_instance.expects(:query_file).never

          get_auth iqdb_queries_path, @user, params: { media_asset_id: @post.media_asset.id }

          assert_response 403
        end
      end

      context "with a file parameter" do
        should "render a response" do
          @matches = [{ post_id: @post.id, score: 90.0 }]
          mock_iqdb_matches(@matches)

          file = Rack::Test::UploadedFile.new("test/files/jpg/test.jpg")
          post_auth iqdb_queries_path(format: :json), @user, params: { search: { file: file }}

          assert_response :success
          assert_equal([{ post_id: @post.id, score: 81.0, post: as(@user) { @post.as_json }}.with_indifferent_access], response.parsed_body)
        end
      end
    end
  end
end
