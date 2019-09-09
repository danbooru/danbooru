require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  context "The posts controller" do
    setup do
      PopularSearchService.stubs(:enabled?).returns(false)

      @user = travel_to(1.month.ago) {create(:user)}
      as_user do
        @post = create(:post, :tag_string => "aaaa")
      end
    end

    context "index action" do
      should "render" do
        get posts_path
        assert_response :success
      end

      context "with a single tag search" do
        should "render for an empty tag" do
          get posts_path, params: { tags: "does_not_exist" }
          assert_response :success
        end

        should "render for an artist tag" do
          create(:post, tag_string: "artist:bkub")
          get posts_path, params: { tags: "bkub" }
          assert_response :success

          artist = create(:artist, name: "bkub")
          get posts_path, params: { tags: "bkub" }
          assert_response :success

          artist.update(is_banned: true)
          get posts_path, params: { tags: "bkub" }
          assert_response :success

          artist.update(is_banned: false, is_active: false)
          get posts_path, params: { tags: "bkub" }
          assert_response :success

          as_user { create(:wiki_page, title: "bkub") }
          get posts_path, params: { tags: "bkub" }
          assert_response :success
        end

        should "render for a tag with a wiki page" do
          create(:post, tag_string: "char:fumimi")
          get posts_path, params: { tags: "fumimi" }
          assert_response :success

          as_user { @wiki = create(:wiki_page, title: "fumimi") }
          get posts_path, params: { tags: "fumimi" }
          assert_response :success

          as_user { @wiki.update(is_deleted: true) }
          get posts_path, params: { tags: "bkub" }
          assert_response :success
        end
      end

      context "with a multi-tag search" do
        should "render" do
          create(:post, tag_string: "1girl solo")
          get posts_path, params: {:tags => "1girl solo"}
          assert_response :success
        end

        should "render an error when searching for too many tags" do
          get posts_path, params: { tags: "1 2 3" }

          assert_response 422
          assert_select "h1", "Search Error"
        end

        should "render an error when exceeding the page limit" do
          get posts_path, params: { page: 1001 }

          assert_response 410
          assert_select "h1", "Search Error"
        end
      end

      context "with an md5 param" do
        should "render" do
          get posts_path, params: { md5: @post.md5 }
          assert_redirected_to(@post)
        end

        should "return error on nonexistent md5" do
          get posts_path(md5: "foo")
          assert_response 404
        end
      end

      context "with a random search" do
        should "render" do
          get posts_path, params: { tags: "order:random" }
          assert_response :success

          get posts_path, params: { random: "1" }
          assert_response :success

          get posts_path(format: :json), params: { random: "1" }
          assert_response :success
        end
      end

      context "with the .atom format" do
        should "render without tags" do
          get posts_path(format: :atom)

          assert_response :success
          assert_select "entry", 1
        end

        should "render with tags" do
          get posts_path(format: :atom), params: { tags: "aaaa" }

          assert_response :success
          assert_select "entry", 1
        end

        should "hide restricted posts" do
          @post.update(is_banned: true)
          get posts_path(format: :atom)

          assert_response :success
          assert_select "entry", 0
        end
      end
    end

    context "show_seq action" do
      should "render" do
        posts = FactoryBot.create_list(:post, 3)

        get show_seq_post_path(posts[1].id), params: { seq: "prev" }
        assert_redirected_to(posts[2])

        get show_seq_post_path(posts[1].id), params: { seq: "next" }
        assert_redirected_to(posts[0])
      end
    end

    context "random action" do
      should "render" do
        get random_posts_path, params: { tags: "aaaa" }
        assert_redirected_to(post_path(@post, tags: "aaaa"))
      end
    end

    context "show action" do
      should "render" do
        get post_path(@post), params: {:id => @post.id}
        assert_response :success
      end

      context "with pools" do
        should "render the pool list" do
          as(@user) { @post.update(tag_string: "newpool:comic") }
          get post_path(@post)

          assert_response :success
          assert_select "#pool-nav .pool-name", /Pool: comic/
        end
      end

      context "with only deleted comments" do
        setup do
          as(@user) { create(:comment, post: @post, is_deleted: true) }
        end

        should "not show deleted comments to regular members" do
          get_auth post_path(@post), @user, params: { id: @post.id }

          assert_response :success
          assert_select "article.comment", 0
          assert_select "a#show-all-comments-link", 0
          assert_select "div.list-of-comments p", /There are no comments/
        end

        should "not show deleted comments to moderators by default, but allow them to be unhidden" do
          mod = create(:mod_user)
          get_auth post_path(@post), mod, params: { id: @post.id }

          assert_response :success
          assert_select "article.comment", 0
          assert_select "a#show-all-comments-link", 1
          assert_select "div.list-of-comments p", /There are no comments/
        end
      end

      context "with only downvoted comments" do
        should "not show thresholded comments" do
          comment = as(@user) { create(:comment, post: @post, score: -10) }
          get_auth post_path(@post), @user, params: { id: @post.id }

          assert_response :success
          assert_select "article.comment", 0
          assert_select "a#show-all-comments-link", 1
          assert_select "div.list-of-comments p", /There are no visible comments/
        end
      end

      context "with a mix of comments" do
        should "not show deleted or thresholded comments " do
          as(@user) { create(:comment, post: @post, do_not_bump_post: true, body: "good") }
          as(@user) { create(:comment, post: @post, do_not_bump_post: true, body: "bad", score: -10) }
          as(@user) { create(:comment, post: @post, do_not_bump_post: true, body: "ugly", is_deleted: true) }

          get_auth post_path(@post), @user, params: { id: @post.id }

          assert_response :success
          assert_select "article.comment", 1
          assert_select "article.comment", /good/
          assert_select "a#show-all-comments-link", 1
        end
      end

      context "when the recommend service is enabled" do
        setup do
          @post2 = create(:post)
          RecommenderService.stubs(:enabled?).returns(true)
          RecommenderService.stubs(:available_for_post?).returns(true)
        end

        should "not error out" do
          get_auth post_path(@post), @user
          assert_response :success
        end
      end

      context "in api responses" do
        should "not include restricted attributes" do
          Post.any_instance.stubs(:visible?).returns(false)
          get_auth post_path(@post), @user, as: :json

          assert_response :success
          assert_nil(response.parsed_body["md5"])
          assert_nil(response.parsed_body["file_url"])
          assert_nil(response.parsed_body["fav_string"])
          assert_equal(@post.uploader_name, response.parsed_body["uploader_name"])
        end
      end
    end

    context "update action" do
      should "work" do
        put_auth post_path(@post), @user, params: {:post => {:tag_string => "bbb"}}
        assert_redirected_to post_path(@post)

        @post.reload
        assert_equal("bbb", @post.tag_string)
      end

      should "ignore restricted params" do
        put_auth post_path(@post), @user, params: {:post => {:last_noted_at => 1.minute.ago}}
        assert_nil(@post.reload.last_noted_at)
      end
    end

    context "revert action" do
      setup do
        PostArchive.sqs_service.stubs(:merge?).returns(false)
        as_user do
          @post.update(tag_string: "zzz")
        end
      end

      should "work" do
        @version = @post.versions.first
        assert_equal("aaaa", @version.tags)
        put_auth revert_post_path(@post), @user, params: {:version_id => @version.id}
        assert_redirected_to post_path(@post)
        @post.reload
        assert_equal("aaaa", @post.tag_string)
      end

      should "not allow reverting to a previous version of another post" do
        as_user do
          @post2 = create(:post, :uploader_id => @user.id, :tag_string => "herp")
        end

        put_auth revert_post_path(@post), @user, params: { :version_id => @post2.versions.first.id }
        @post.reload
        assert_not_equal(@post.tag_string, @post2.tag_string)
        assert_response :missing
      end
    end
  end
end
