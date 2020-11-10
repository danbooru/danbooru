require 'test_helper'

class UploadsControllerTest < ActionDispatch::IntegrationTest
  def self.should_upload_successfully(source)
    should "upload successfully from #{source}" do
      assert_successful_upload(source, user: create(:user, created_at: 1.month.ago))
    end
  end

  def assert_successful_upload(source_or_file_path, user: @user, **params)
    if source_or_file_path =~ %r{\Ahttps?://}i
      source = { source: source_or_file_path }
    else
      file = Rack::Test::UploadedFile.new(Rails.root.join(source_or_file_path))
      source = { file: file }
    end

    assert_difference(["Upload.count"]) do
      post_auth uploads_path, user, params: { upload: { tag_string: "abc", rating: "e", **source, **params }}
    end

    upload = Upload.last
    assert_response :redirect
    assert_redirected_to upload
    assert_equal("completed", upload.status)
    assert_equal(Post.last, upload.post)
    assert_equal(upload.post.md5, upload.md5)
    upload
  end

  context "The uploads controller" do
    setup do
      @user = create(:contributor_user, name: "marisa")
      mock_iqdb_service!
    end

    context "image proxy action" do
      should "work" do
        url = "https://i.pximg.net/img-original/img/2017/11/21/17/06/44/65985331_p0.png"
        get_auth image_proxy_uploads_path, @user, params: { url: url }

        assert_response :success
        assert_equal("image/png", response.media_type)
        assert_equal(15_573, response.body.size)
      end
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
          @post = as(@user) { create(:post, source: "http://google.com/aaa") }
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
        as(@user) do
          @upload = create(:upload, tag_string: "foo bar", source: "http://example.com/foobar")
          @post_upload = create(:source_upload, status: "completed", post: build(:post, tag_string: "touhou"), rating: "e")
        end
        as(create(:user)) do
          @upload3 = create(:upload)
        end
      end

      should "render" do
        get uploads_path
        assert_response :success
      end

      context "as an uploader" do
        setup do
          CurrentUser.user = @user
        end

        should respond_to_search({}).with { [@post_upload, @upload] }
        should respond_to_search(source: "http://example.com/foobar").with { @upload }
        should respond_to_search(rating: "e").with { @post_upload }
        should respond_to_search(tag_string: "*foo*").with { @upload }

        context "using includes" do
          should respond_to_search(post_tags_match: "touhou").with { @post_upload }
          should respond_to_search(uploader: {name: "marisa"}).with { [@post_upload, @upload] }
        end
      end

      context "as an admin" do
        setup do
          CurrentUser.user = create(:admin_user)
        end

        should respond_to_search({}).with { [@upload3, @post_upload, @upload] }
      end
    end

    context "show action" do
      setup do
        @upload = as(@user) { create(:jpg_upload) }
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
            as(@user) do
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
            @upload = as(@user) { create(:upload, status: "preprocessed", source: @source, referer_url: @ref, image_width: 0, image_height: 0, file_size: 0, md5: "something", file_ext: "jpg") }
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

      context "when the upload is tagged banned_artist" do
        should "autoban the post" do
          upload = assert_successful_upload("test/files/test.jpg", tag_string: "banned_artist")
          assert_equal(true, upload.post.is_banned?)
        end
      end

      context "when the upload is tagged paid_reward" do
        should "autoban the post" do
          upload = assert_successful_upload("test/files/test.jpg", tag_string: "paid_reward")
          assert_equal(true, upload.post.is_banned?)
        end
      end

      context "uploading a file from your computer" do
        should_upload_successfully("test/files/test.jpg")
        should_upload_successfully("test/files/test.png")
        should_upload_successfully("test/files/test-static-32x32.gif")
        should_upload_successfully("test/files/test-animated-86x52.gif")
        should_upload_successfully("test/files/test-300x300.mp4")
        should_upload_successfully("test/files/test-512x512.webm")
        should_upload_successfully("test/files/compressed.swf")
      end

      context "uploading a file from a source" do
        should_upload_successfully("https://www.artstation.com/artwork/04XA4")
        should_upload_successfully("https://dantewontdie.artstation.com/projects/YZK5q")
        should_upload_successfully("https://cdna.artstation.com/p/assets/images/images/006/029/978/large/amama-l-z.jpg")

        should_upload_successfully("https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484")
        should_upload_successfully("https://noizave.deviantart.com/art/test-no-download-697415967")
        should_upload_successfully("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg")

        should_upload_successfully("https://www.hentai-foundry.com/pictures/user/Afrobull/795025/kuroeda")
        should_upload_successfully("https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png")

        should_upload_successfully("https://yande.re/post/show/482880")
        should_upload_successfully("https://files.yande.re/image/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880.jpg")

        should_upload_successfully("https://konachan.com/post/show/270916")
        should_upload_successfully("https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png")

        should_upload_successfully("http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663")
        should_upload_successfully("http://seiga.nicovideo.jp/seiga/im4937663")
        should_upload_successfully("https://seiga.nicovideo.jp/image/source/9146749")
        should_upload_successfully("https://seiga.nicovideo.jp/watch/mg389884")
        should_upload_successfully("https://dic.nicovideo.jp/oekaki/52833.png")
        should_upload_successfully("https://lohas.nicoseiga.jp/o/971eb8af9bbcde5c2e51d5ef3a2f62d6d9ff5552/1589933964/3583893")
        should_upload_successfully("http://lohas.nicoseiga.jp/priv/3521156?e=1382558156&h=f2e089256abd1d453a455ec8f317a6c703e2cedf")
        should_upload_successfully("http://lohas.nicoseiga.jp/priv/b80f86c0d8591b217e7513a9e175e94e00f3c7a1/1384936074/3583893")
        should_upload_successfully("http://lohas.nicoseiga.jp/material/5746c5/4459092")
        # XXX should_upload_successfully("https://dcdn.cdn.nimg.jp/priv/62a56a7f67d3d3746ae5712db9cac7d465f4a339/1592186183/10466669")
        # XXX should_upload_successfully("https://dcdn.cdn.nimg.jp/nicoseiga/lohas/o/8ba0a9b2ea34e1ef3b5cc50785bd10cd63ec7e4a/1592187477/10466669")

        should_upload_successfully("http://nijie.info/view.php?id=213043")
        should_upload_successfully("https://nijie.info/view_popup.php?id=213043")
        should_upload_successfully("https://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg")

        should_upload_successfully("https://pawoo.net/web/statuses/1202176")
        should_upload_successfully("https://img.pawoo.net/media_attachments/files/000/128/953/original/4c0a06087b03343f.png")

        should_upload_successfully("https://www.pixiv.net/en/artworks/64476642")
        should_upload_successfully("https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg")

        should_upload_successfully("https://noizave.tumblr.com/post/162206271767")
        should_upload_successfully("https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png")

        should_upload_successfully("https://twitter.com/noizave/status/875768175136317440")
        should_upload_successfully("https://pbs.twimg.com/media/DCdZ_FhUIAAYKFN?format=jpg&name=medium")
        should_upload_successfully("https://pbs.twimg.com/profile_banners/1130156172399353857/1597419344/1500x500")
        # XXX should_upload_successfully("https://video.twimg.com/tweet_video/EWHWVrmVcAAp4Vw.mp4")

        should_upload_successfully("https://www.weibo.com/5501756072/J2UNKfbqV")
        should_upload_successfully("https://wx1.sinaimg.cn/mw690/0060kO5aly1gezsyt5xvhj30ok0sgtc9.jpg")

        should_upload_successfully("https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg")
        should_upload_successfully("https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg")
        should_upload_successfully("https://www.newgrounds.com/art/view/puddbytes/costanza-at-bat")

        should_upload_successfully("https://kmyama.fanbox.cc/posts/104708")
        should_upload_successfully("https://downloads.fanbox.cc/images/post/104708/wsF73EC5Fq0CIK84W0LGYk2p.jpeg")
      end
    end
  end
end
