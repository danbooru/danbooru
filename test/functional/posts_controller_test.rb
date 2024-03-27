require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  def assert_seo_canonical_url_equals(expected)
    assert_equal(expected, response.parsed_body.css("link[rel=canonical]").attribute("href").value)
  end

  def assert_post_source_equals(expected_source, source_url, page_url = nil)
    post = create_post!(source_url: source_url, page_url: page_url)

    assert_response :redirect
    assert_equal(expected_source, post.source)
  end

  def create_post!(user: create(:user), media_asset: build(:media_asset), rating: "q", tag_string: "tagme", source_url: nil, page_url: nil, **params)
    upload = build(:upload, uploader: user, media_asset_count: 1, status: "completed")
    asset = create(:upload_media_asset, upload: upload, media_asset: media_asset, **{ source_url: source_url, page_url: page_url }.compact_blank)

    RateLimit.delete_all
    post_auth posts_path, user, params: { upload_media_asset_id: asset.id, post: { rating: rating, source: asset.canonical_url, tag_string: tag_string, **params }}

    Post.last
  end

  context "The posts controller" do
    setup do
      @user = travel_to(1.month.ago) {create(:user)}
      @post = as(@user) { create(:post, tag_string: "aaaa") }
      Danbooru.config.stubs(:canonical_url).returns("http://www.example.com")
    end

    context "index action" do
      setup do
        mock_post_search_rankings(Date.today, [["1girl", 100], ["original", 50]])
        create_list(:post, 2)
      end

      context "when using sequential pagination" do
        should "work with page=a0" do
          get posts_path(page: "a0")
          assert_response :success
          assert_select ".post-preview", count: 3
          assert_select "a.paginator-prev", count: 0
          assert_select "a.paginator-next", count: 1
        end

        should "work with page=b0" do
          get posts_path(page: "b0")
          assert_response :success
          assert_select ".post-preview", count: 0
          assert_select "a.paginator-prev", count: 0
          assert_select "a.paginator-next", count: 0
        end

        should "work with page=b100000" do
          get posts_path(page: "b100000")
          assert_response :success
          assert_select ".post-preview", count: 3
          assert_select "a.paginator-prev", count: 1
          assert_select "a.paginator-next", count: 0
        end

        should "work with page=a100000" do
          get posts_path(page: "a100000")
          assert_response :success
          assert_select ".post-preview", count: 0
          assert_select "a.paginator-prev", count: 0
          assert_select "a.paginator-next", count: 0
        end
      end

      context "for an empty search" do
        should "render the first page" do
          get root_path
          assert_response :success
          assert_seo_canonical_url_equals(root_url)

          get posts_path
          assert_response :success
          assert_seo_canonical_url_equals(root_url)

          get posts_path(page: 1)
          assert_response :success
          assert_seo_canonical_url_equals(root_url)
        end

        should "render the second page" do
          get posts_path(page: 2, limit: 1)
          assert_response :success
          assert_seo_canonical_url_equals(posts_url(page: 2, limit: 1))
        end
      end

      context "with a single tag search" do
        should "render for an empty tag" do
          get posts_path, params: { tags: "does_not_exist" }
          assert_response :success
          assert_select "#show-excerpt-link", count: 0
          assert_seo_canonical_url_equals(posts_url(tags: "does_not_exist"))
        end

        should "render for an artist tag" do
          as(@user) { create(:post, tag_string: "artist:bkub", rating: "s") }
          get posts_path, params: { tags: "bkub" }
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Artist"

          artist = create(:artist, name: "bkub")
          get posts_path, params: { tags: "bkub" }
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Artist"
          assert_select "#view-wiki-link", count: 0
          assert_select "#view-artist-link", count: 1

          artist.update(is_banned: true)
          get posts_path, params: { tags: "bkub" }
          assert_response 451

          artist.update(is_banned: false, is_deleted: true)
          get posts_path, params: { tags: "bkub" }
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Artist"

          as(@user) { create(:wiki_page, title: "bkub") }
          get posts_path, params: { tags: "bkub" }
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Artist"
          assert_select "#view-wiki-link", count: 0
          assert_select "#view-artist-link", count: 0
        end

        should "render for a banned artist tag" do
          artist = create(:artist, is_banned: true)
          create(:post, tag_string: artist.name)
          get posts_path, params: { tags: artist.name }

          assert_response 451
        end

        should "render for a tag with a wiki page" do
          as(@user) { create(:post, tag_string: "char:fumimi", rating: "s") }
          get posts_path, params: { tags: "fumimi" }
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Wiki"

          @wiki = as(@user) { create(:wiki_page, title: "fumimi") }
          get posts_path, params: { tags: "fumimi" }
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Wiki"

          as(@user) { @wiki.update(is_deleted: true) }
          get posts_path, params: { tags: "bkub" }
          assert_response :success
          assert_select "#show-excerpt-link", count: 0
        end

        should "render for an aliased tag" do
          create(:tag_alias, antecedent_name: "lav", consequent_name: "looking_at_viewer")
          as(@user) { create(:wiki_page, title: "looking_at_viewer") }
          @post = create(:post, tag_string: "looking_at_viewer", rating: "s")

          get posts_path, params: { tags: "lav" }
          assert_response :success
          assert_select "#post_#{@post.id}", count: 1
          assert_select "#excerpt .wiki-link[href='/wiki_pages/looking_at_viewer']", count: 1
        end

        should "render for a wildcard tag search" do
          create(:post, tag_string: "1girl solo")
          get posts_path(tags: "*girl*")
          assert_response :success
          assert_select "#show-excerpt-link", count: 0
        end

        should "render for a search:all search" do
          create(:saved_search, user: @user)
          get posts_path(tags: "search:all")
          assert_response :success
        end

        should "show the wiki excerpt for a wiki page without a tag" do
          as(@user) { create(:wiki_page, title: "no_tag") }
          get posts_path(tags: "no_tag")
          assert_select "#show-excerpt-link", count: 1
          assert_select "#excerpt", count: 1
        end

        should "show a notice for a single tag search with a pending BUR" do
          create(:post, tag_string: "foo")
          create(:bulk_update_request, script: "create alias foo -> bar")
          get_auth posts_path(tags: "foo"), @user
          assert_select ".tag-change-notice"
        end

        should "show a notice for a single tag search with multiple pending BURs in multiple topics" do
          topic1 = as(@user) { create(:forum_topic) }
          topic2 = as(@user) { create(:forum_topic) }
          create(:post, tag_string: "foo")
          create(:bulk_update_request, script: "create alias foo -> bar", forum_topic: topic1)
          create(:bulk_update_request, script: "create alias foo -> baz", forum_topic: topic1)
          create(:bulk_update_request, script: "create alias foo -> qux", forum_topic: topic2)
          create(:bulk_update_request, script: "create alias foo -> blah", forum_topic: topic2)

          get_auth posts_path(tags: "foo"), @user
          assert_select ".tag-change-notice"
        end

        should "show deleted posts for a status:DELETED search" do
          create(:post, is_deleted: true)
          get_auth posts_path(tags: "status:DELETED"), @user
          assert_select ".post-preview.post-status-deleted", count: 1
        end
      end

      context "with a multi-tag search" do
        should "render" do
          as(create(:user)) do
            create(:post, tag_string: "1girl solo", rating: "s")
            create(:wiki_page, title: "1girl")
          end

          get posts_path, params: {:tags => "1girl solo"}
          assert_response :success
          assert_select "#show-excerpt-link", count: 0
        end

        should "show the wiki excerpt if the search has a tag with a wiki" do
          as(@user) { create(:wiki_page, title: "1girl") }
          create(:post, tag_string: "1girl rating:s")
          get posts_path, params: { tags: "1girl rating:s" }

          assert_response :success
          assert_select "a.wiki-excerpt-link", count: 1
        end

        should "show the blank wiki excerpt if the search has tag without a wiki" do
          create(:post, tag_string: "1girl rating:s")
          get posts_path, params: { tags: "1girl rating:s" }

          assert_response :success
          assert_select "a.blank-wiki-excerpt-link", count: 1
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

        should "render if the search count times out" do
          PostQuery.any_instance.stubs(:exact_count).returns(nil)
          get posts_path, params: { tags: "1girl", safe_mode: "true" }

          assert_response :success
        end
      end

      context "with a pool: search" do
        setup do
          CurrentUser.user = create(:user)
        end

        teardown do
          CurrentUser.user = nil
        end

        should "render for a pool: search" do
          pool1 = create(:pool)
          pool2 = create(:pool)
          create(:post, tag_string: "solo pool:#{pool1.id}", rating: "s")
          create(:wiki_page, title: "solo")

          get posts_path(tags: "pool:#{pool1.id}")
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Pool"

          get posts_path(tags: "pool:#{pool1.id} rating:s")
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Pool"

          get posts_path(tags: "pool:#{pool1.id} solo")
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Wiki"

          get posts_path(tags: "pool:#{pool1.id} -pool:#{pool2.id}")
          assert_response :success
          assert_select "#show-excerpt-link", count: 0
        end
      end

      context "with a favgroup: search" do
        setup do
          CurrentUser.user = create(:user)
        end

        teardown do
          CurrentUser.user = nil
        end

        should "render for a favgroup: search" do
          wiki = create(:wiki_page, title: "solo")
          post1 = create(:post, tag_string: "solo", rating: "s")
          favgroup1 = create(:favorite_group, post_ids: [post1.id])
          favgroup2 = create(:favorite_group)

          get posts_path(tags: "favgroup:#{favgroup1.id}")
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Favorite Group"

          get posts_path(tags: "favgroup:#{favgroup1.id} rating:s")
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Favorite Group"

          get posts_path(tags: "favgroup:#{favgroup1.id} solo")
          assert_response :success
          assert_select "#show-excerpt-link", count: 1, text: "Wiki"

          get posts_path(tags: "favgroup:#{favgroup1.id} -favgroup:#{favgroup2.id}")
          assert_response :success
          assert_select "#show-excerpt-link", count: 0
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

          get posts_path(tags: "random:1")
          assert_response :success

          get posts_path(random: "1")
          assert_redirected_to posts_path(tags: "random:20", format: :html)

          get posts_path(random: "1"), as: :json
          assert_redirected_to posts_path(tags: "random:20", format: :json)

          get posts_path(tags: "touhou", random: "true")
          assert_redirected_to posts_path(tags: "touhou random:20", format: :html)
        end

        should "render with multiple posts" do
          @posts = create_list(:post, 2)

          get posts_path(random: "1")
          assert_redirected_to posts_path(tags: "random:20", format: :html)
        end

        should "return all posts for a .json response" do
          create_list(:post, 2, tag_string: "honk_honk")
          get posts_path, params: { tags: "honk_honk order:random" }, as: :json

          assert_response :success
          assert_equal(true, response.parsed_body.is_a?(Array))
          assert_equal(2, response.parsed_body.size)
        end
      end

      context "with the .atom format" do
        should "render without tags" do
          get posts_path(format: :atom)

          assert_response :success
          assert_select "entry", 3
        end

        should "render with tags" do
          get posts_path(format: :atom), params: { tags: "aaaa" }

          assert_response :success
          assert_select "entry", 1
        end

        should "hide restricted posts" do
          Post.update_all(is_banned: true)
          get posts_path(format: :atom)

          assert_response :success
          assert_select "entry", 0
        end
      end

      context "with the .sitemap format" do
        should "render" do
          get posts_path(format: :sitemap)
          assert_response :success
          assert_equal(Post.count, response.parsed_body.css("urlset url loc").size)
        end
      end

      context "with deleted posts" do
        setup do
          @post.update!(is_deleted: true)
        end

        should "not show deleted posts normally" do
          get posts_path
          assert_response :success
          assert_select "#post_#{@post.id}", 0
        end

        should "show deleted posts when searching for status:deleted" do
          get posts_path(tags: "status:deleted")
          assert_response :success
          assert_select "#post_#{@post.id}", 1
        end

        should 'show deleted posts when searching for status:"deleted"' do
          get posts_path(tags: 'status:"deleted"')
          assert_response :success
          assert_select "#post_#{@post.id}", 1
        end

        should "show deleted posts when searching for -status:active" do
          get posts_path(tags: "-status:active")
          assert_response :success
          assert_select "#post_#{@post.id}", 1
        end
      end

      context "with restricted posts" do
        setup do
          as(@user) { @post.update!(tag_string: "tagme") }
        end

        should "not show restricted posts if user doesn't have permission" do
          Post.any_instance.stubs(:levelblocked?).returns(true)
          get posts_path
          assert_response :success
          assert_select "#post_#{@post.id}", 0
        end

        should "show restricted posts if user has permission" do
          Post.any_instance.stubs(:levelblocked?).returns(false)
          get_auth posts_path, create(:gold_user)
          assert_response :success
          assert_select "#post_#{@post.id}", 1
        end
      end

      context "with banned paid_reward posts" do
        setup do
          as(@user) { @post.update!(tag_string: "paid_reward", is_banned: true) }
        end

        should "show banned paid_rewards to approvers" do
          get_auth posts_path, create(:approver)
          assert_response :success
          assert_select "#post_#{@post.id}", 1
        end

        should "not show banned paid_rewards to non-approvers" do
          get_auth posts_path, create(:gold_user)
          assert_response :success
          assert_select "#post_#{@post.id}", 0
        end
      end

      context "in safe mode" do
        should "not include the rating:s tag in the page title" do
          Danbooru.config.stubs(:app_name).returns("Safebooru")

          get posts_path(tags: "fate/grand_order", safe_mode: true)
          assert_select "title", text: "Fate/Grand Order | Safebooru"
        end
      end

      context "for a search that times out" do
        context "during numbered pagination" do
          should "show the search timeout error page" do
            PostSets::Post.any_instance.stubs(:posts).raises(ActiveRecord::QueryCanceled)

            get posts_path(page: "1")
            assert_response 500
            assert_select "h1", text: "Search Timeout"
          end
        end

        context "during sequential pagination" do
          should "show the search timeout error page" do
            PostSets::Post.any_instance.stubs(:posts).raises(ActiveRecord::QueryCanceled)

            get posts_path(page: "a0")
            assert_response 500
            assert_select "h1", text: "Search Timeout"
          end
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
        assert_redirected_to(post_path(@post, q: "aaaa"))
      end

      should "render for a ordfav: search" do
        @post = as(@user) { create(:post, tag_string: "fav:me") }
        get random_posts_path, params: { tags: "ordfav:#{@user.name}" }

        assert_redirected_to(post_path(@post, q: "ordfav:#{@user.name}"))
      end

      should "return a 404 when no random posts can be found" do
        get random_posts_path, params: { tags: "qoigjegoi" }
        assert_response 404
      end
    end

    context "show action" do
      should "render" do
        get post_path(@post), params: {:id => @post.id}
        assert_response :success
      end

      context "with everything" do
        setup do
          @admin = create(:admin_user)
          @approver = create(:approver_user)

          as(@user) do
            @post.update!(tag_string: "1girl solo highres blah 2001")
            Tag.find_by_name("1girl").update(post_count: 20_000)
            Tag.find_by_name("solo").update(post_count: 2_000)
            Tag.find_by_name("blah").update(post_count: 1)

            @pool = create(:pool)
            @pool.add!(@post)

            @favgroup = create(:favorite_group, post_ids: [@post.id])

            @comment = create(:comment, post: @post, creator: @admin)
            create(:comment_vote, comment: @comment, user: @user)

            create(:note, post: @post)
            create(:artist_commentary, post: @post)
            create(:post_flag, post: @post, creator: @user)
            #create(:post_appeal, post: @post, creator: @user)
            create(:post_vote, post: @post, user: @user)
            create(:favorite, post: @post, user: @user)
            create(:moderation_report, model: @comment, creator: @approver)
          end
        end

        should "render for an anonymous user" do
          get post_path(@post)
          assert_response :success
        end

        should "render for a member" do
          get_auth post_path(@post), @user
          assert_response :success
        end

        should "render for a builder" do
          get_auth post_path(@post), @approver
          assert_response :success
        end

        should "render for an admin" do
          get_auth post_path(@post), @admin
          assert_response :success
        end

        should "render for a builder with a search query" do
          get_auth post_path(@post, q: "tagme"), @approver
          assert_response :success
        end

        should "render the flag edit link for the flagger" do
          get_auth post_path(@post), @user

          assert_response :success
          assert_select ".post-flag-reason a:first", "edit"
        end
      end

      context "a deleted post" do
        should "render" do
          @post.delete!("no", user: @user)
          get post_path(@post)

          assert_response :success
        end
      end

      context "a nonexistent post id" do
        should "return 404" do
          get post_path(id: 9_999_999)

          assert_response 404
        end
      end

      context "with pools" do
        should "render the pool list" do
          as(@user) { @post.update(tag_string: "newpool:comic") }
          get post_path(@post)

          assert_response :success
          assert_select ".pool-navbar .pool-name", /Pool: comic/
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
        end
      end

      context "with a non-web source" do
        should "render" do
          @post.update!(source: "Blog.")
          get post_path(@post)

          assert_response :success
        end
      end

      should "respect the disable tagged filenames option in the Download link" do
        @user.update!(disable_tagged_filenames: true)
        get_auth post_path(@post), @user

        assert_response :success
        assert_equal("#{@post.md5}.#{@post.file_ext}", response.parsed_body.css("#post-option-download a").attr("download").value)
      end
    end

    context "create action" do
      should "create a post" do
        @post = create_post!(rating: "s", tag_string: "test")

        assert_redirected_to @post
        assert_equal("s", @post.rating)
        assert_equal("test", @post.tag_string)
      end

      should "re-render the upload page if the upload fails" do
        @post = create_post!(rating: "z", tag_string: "tagme")
        assert_response :success
      end

      should "re-render the upload page if the rating is not selected" do
        assert_no_difference("Post.count") do
          @post = create_post!(rating: "", tag_string: "tagme")
        end

        assert_response :success
        assert_equal("Rating not selected", flash[:notice])
      end

      should "merge the tags and redirect to the original post if the upload is a duplicate of an existing post" do
        media_asset = create(:media_asset)
        post1 = create_post!(rating: "s", tag_string: "post1", media_asset: media_asset)
        post2 = create_post!(rating: "e", tag_string: "post2", media_asset: media_asset)

        assert_redirected_to post1
        assert_equal("post1 post2", post1.reload.tag_string)
        assert_equal("e", post1.rating)
      end

      should "apply the rating from the tags" do
        @post = create_post!(rating: nil, tag_string: "rating:s")

        assert_redirected_to @post
        assert_equal("s", @post.rating)
        assert_equal("tagme", @post.tag_string)
      end

      should "set the source" do
        @post = create_post!(source: "https://www.example.com")

        assert_redirected_to @post
        assert_equal("https://www.example.com", @post.source)
      end

      should "autoban the post when it is tagged banned_artist" do
        @post = create_post!(tag_string: "banned_artist")
        assert_equal(true, @post.is_banned?)
      end

      should "autoban the post if it is tagged paid_reward" do
        @post = create_post!(tag_string: "paid_reward")
        assert_equal(true, @post.is_banned?)
      end

      should "not create a post when the uploader is upload-limited" do
        @user = create(:user, upload_points: 0)

        @user.upload_limit.upload_slots.times do
          assert_difference("Post.count", 1) do
            create_post!(user: @user)
          end
        end

        assert_no_difference("Post.count") do
          create_post!(user: @user)
        end
      end

      should "mark the post as pending for Member users" do
        @post = create_post!(user: create(:user), is_pending: false)
        assert_equal(true, @post.is_pending?)
      end

      should "mark the post as active for users with unrestricted uploads" do
        @post = create_post!(user: create(:contributor_user))
        assert_equal(false, @post.is_pending?)
      end

      should "mark the post as pending for users with unrestricted uploads who upload for approval" do
        @post = create_post!(user: create(:contributor_user), is_pending: true)
        assert_equal(true, @post.is_pending?)
      end

      should "create a commentary record if the commentary is present" do
        assert_difference("ArtistCommentary.count", 1) do
          @post = create_post!(
            user: @user,
            artist_commentary_title: "original title",
            artist_commentary_desc: "original desc",
            translated_commentary_title: "translated title",
            translated_commentary_desc: "translated desc",
          )
        end

        assert_equal(true, @post.artist_commentary.present?)
        assert_equal("original title", @post.artist_commentary.original_title)
        assert_equal("original desc", @post.artist_commentary.original_description)
        assert_equal("translated title", @post.artist_commentary.translated_title)
        assert_equal("translated desc", @post.artist_commentary.translated_description)
      end

      should "create a commentary record if a single commentary field is present" do
        assert_difference("ArtistCommentary.count", 1) do
          @post = create_post!(
            user: @user,
            artist_commentary_title: "title",
          )
        end

        assert_equal(true, @post.artist_commentary.present?)
        assert_equal("title", @post.artist_commentary.original_title)
        assert_equal("", @post.artist_commentary.original_description)
        assert_equal("", @post.artist_commentary.translated_title)
        assert_equal("", @post.artist_commentary.translated_description)
      end

      should "not create a commentary record if the commentary is blank" do
        assert_no_difference("ArtistCommentary.count") do
          @post = create_post!(
            user: @user,
            artist_commentary_title: "",
            artist_commentary_desc: "",
            translated_commentary_title: "",
            translated_commentary_desc: "",
          )
        end

        assert_equal(false, @post.artist_commentary.present?)
      end

      should "set the correct source after upload" do
        assert_post_source_equals("https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg", "https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg")
        assert_post_source_equals("https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg", "https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg", "https://www.pixiv.net/en/artworks/64476642")

        assert_post_source_equals("https://pbs.twimg.com/media/DCdZ_FhUIAAYKFN.jpg:orig", "https://pbs.twimg.com/media/DCdZ_FhUIAAYKFN.jpg:orig")
        assert_post_source_equals("https://twitter.com/noizave/status/875768175136317440", "https://pbs.twimg.com/media/DCdZ_FhUIAAYKFN.jpg:orig", "https://twitter.com/noizave/status/875768175136317440")

        assert_post_source_equals("https://noizave.tumblr.com/post/162206271767", "https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png")

        assert_post_source_equals(
          "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg",
          "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg"
        )

        assert_post_source_equals(
          "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg",
          "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg",
          "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896"
        )

        assert_post_source_equals("https://cdna.artstation.com/p/assets/images/images/000/705/368/large/jey-rain-one1.jpg?1443931773", "https://cdna.artstation.com/p/assets/images/images/000/705/368/large/jey-rain-one1.jpg?1443931773")
        assert_post_source_equals("https://jeyrain.artstation.com/projects/04XA4", "https://cdna.artstation.com/p/assets/images/images/000/705/368/large/jey-rain-one1.jpg?1443931773", "https://www.artstation.com/artwork/04XA4")

        assert_post_source_equals("https://i0.hdslb.com/bfs/album/669c0974a2a7508cbbb60b185eddaa0ccf8c5b7a.jpg", "https://i0.hdslb.com/bfs/album/669c0974a2a7508cbbb60b185eddaa0ccf8c5b7a.jpg")
        assert_post_source_equals("https://h.bilibili.com/83341894", "https://i0.hdslb.com/bfs/album/669c0974a2a7508cbbb60b185eddaa0ccf8c5b7a.jpg", "https://h.bilibili.com/83341894")

        assert_post_source_equals("https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg", "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg")
        assert_post_source_equals("https://t.bilibili.com/686082748803186697", "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg", "https://t.bilibili.com/686082748803186697")

        assert_post_source_equals("https://i.4cdn.org/vt/1611919211191.jpg", "https://i.4cdn.org/vt/1611919211191.jpg")
        assert_post_source_equals("https://boards.4channel.org/vt/thread/1#p1", "https://i.4cdn.org/vt/1611919211191.jpg", "https://boards.4channel.org/vt/thread/1")
      end
    end

    context "update action" do
      should "redirect to the post on success" do
        put_auth post_path(@post), @user, params: {:post => {:tag_string => "bbb"}}
        assert_redirected_to post_path(@post)

        @post.reload
        assert_equal("bbb", @post.tag_string)
      end

      should "ignore restricted params" do
        put_auth post_path(@post), @user, params: {:post => {:last_noted_at => 1.minute.ago}}
        assert_nil(@post.reload.last_noted_at)
      end

      should "not allow unprivileged users to update restricted posts" do
        as(@user) { @post.update!(is_banned: true) }
        put_auth post_path(@post), @user, params: { post: { tag_string: "blah" }}
        assert_response 403
        assert_not_equal("blah", @post.reload.tag_string)
      end

      should "not allow unverified users to update posts" do
        put_auth post_path(@post), create(:restricted_user), params: { post: { tag_string: "blah" }}
        assert_response 403
        assert_not_equal("blah", @post.reload.tag_string)
      end

      should "not raise an exception on validation error" do
        put_auth post_path(@post), @user, params: { post: { parent_id: @post.id }}
        assert_redirected_to post_path(@post)

        assert_nil(@post.parent_id)
      end
    end

    context "destroy action" do
      setup do
        @approver = create(:approver)
      end

      should "delete the post" do
        delete_auth post_path(@post), @approver, params: { commit: "Delete", post: { reason: "test" } }

        assert_redirected_to @post
        assert_equal(true, @post.reload.is_deleted?)
        assert_equal("test", @post.flags.last.reason)
      end

      should "delete the post if the post is currently flagged" do
        create(:post_flag, post: @post, reason: "blah")
        delete_auth post_path(@post), @approver, params: { commit: "Delete", post: { reason: "test" } }

        assert_redirected_to @post
        assert_equal(true, @post.reload.is_deleted?)
        assert_equal("blah", @post.flags.first.reason)
        assert_equal("test", @post.flags.last.reason)
        assert_equal(2, @post.flags.count)
      end

      should "delete the post even if the deleter has flagged the post previously" do
        create(:post_flag, post: @post, creator: @approver, created_at: 7.days.ago, status: "rejected", reason: "blah")
        delete_auth post_path(@post), @approver, params: { commit: "Delete", post: { reason: "test" } }

        assert_redirected_to @post
        assert_equal(true, @post.reload.is_deleted?)
        assert_equal("blah", @post.flags.first.reason)
        assert_equal("test", @post.flags.last.reason)
        assert_equal(2, @post.flags.count)
      end

      should "not delete the post if the post is already deleted" do
        delete_auth post_path(@post), @user, params: { commit: "Delete" }

        assert_response 403
        assert_equal(false, @post.is_deleted?)
        assert_equal(0, @post.flags.count)
      end

      should "not delete the post if the user is unauthorized" do
        delete_auth post_path(@post), @user, params: { commit: "Delete" }

        assert_response 403
        assert_equal(false, @post.is_deleted?)
        assert_equal(0, @post.flags.count)
      end

      should "render the delete post dialog for an xhr request" do
        delete_auth post_path(@post), @approver, xhr: true

        assert_response :success
        assert_equal(false, @post.is_deleted?)
      end
    end

    context "revert action" do
      setup do
        PostVersion.sqs_service.stubs(:merge?).returns(false)
        as(@user) { @post.update(tag_string: "zzz") }
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
        @post2 = as(@user) { create(:post, uploader_id: @user.id, tag_string: "herp") }

        put_auth revert_post_path(@post), @user, params: { :version_id => @post2.versions.first.id }
        @post.reload
        assert_not_equal(@post.tag_string, @post2.tag_string)
        assert_response :missing
      end
    end

    context "copy_notes action" do
      setup do
        as(@user) do
          @src = create(:post, image_width: 100, image_height: 100, tag_string: "translated partially_translated", has_embedded_notes: true)
          @dst = create(:post, image_width: 200, image_height: 200, tag_string: "translation_request")
          create(:note, post: @src, x: 10, y: 10, width: 10, height: 10, body: "test")
          create(:note, post: @src, x: 10, y: 10, width: 10, height: 10, body: "deleted", is_active: false)
        end
      end

      should "copy notes and tags" do
        put_auth copy_notes_post_path(@src), @user, params: { other_post_id: @dst.id }
        assert_response :success

        assert_equal(1, @dst.reload.notes.active.length)
        assert_equal(true, @dst.has_embedded_notes)
        assert_equal("lowres partially_translated translated", @dst.tag_string)
      end

      should "rescale notes" do
        put_auth copy_notes_post_path(@src), @user, params: { other_post_id: @dst.id }
        assert_response :success

        note = @dst.notes.active.first
        assert_equal([20, 20, 20, 20], [note.x, note.y, note.width, note.height])
      end
    end

    context "mark_as_translated action" do
      should "mark the post as translated" do
        put_auth mark_as_translated_post_path(@post), @user, params: { post: { check_translation: false, partially_translated: false }}
        assert_redirected_to @post
        assert(@post.reload.has_tag?("translated"))
      end
    end
  end
end
