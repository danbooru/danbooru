require 'test_helper'

class UploadsControllerTest < ActionDispatch::IntegrationTest
  context "The uploads controller" do
    setup do
      @user = create(:user)
    end

    context "batch action" do
      should "redirect to the new upload page" do
        get batch_uploads_path(url: "https://twitter.com/lvlln/status/567054278486151168")

        assert_redirected_to new_upload_path(url: "https://twitter.com/lvlln/status/567054278486151168")
      end
    end

    context "new action" do
      should "render" do
        get_auth new_upload_path, @user
        assert_response :success
      end

      should "render with an url" do
        get_auth new_upload_path(url: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"), @user
        assert_response :success
      end
    end

    context "index action" do
      should "render as an anonymous user" do
        create(:completed_source_upload, uploader: @user)
        get uploads_path

        assert_response :success
      end

      should "render as an uploader" do
        create(:completed_source_upload, uploader: @user)
        get_auth uploads_path, @user

        assert_response :success
      end

      should "render as an admin" do
        create(:completed_source_upload, uploader: @user)
        get_auth uploads_path, create(:admin_user)

        assert_response :success
      end

      context "for a search" do
        setup do
          CurrentUser.user = @user
          @upload = create(:completed_source_upload, uploader: @user, source: "http://example.com/foobar")
        end

        should respond_to_search({}).with { [@upload] }
        should respond_to_search(source: "http://example.com/foobar").with { @upload }
        should respond_to_search(status: "completed").with { @upload }
        should respond_to_search(media_assets: { file_size: 1_000_000 }).with { @upload }
        should respond_to_search(media_assets: { md5: "blah" }).with { }
      end
    end

    context "show action" do
      should "not show uploads to other users" do
        upload = create(:completed_source_upload, uploader: @user)
        get_auth upload_path(upload), create(:user)

        assert_response 403
      end

      should "render a completed source upload for the uploader" do
        upload = create(:completed_source_upload, uploader: @user)
        get_auth upload_path(upload), @user

        assert_response :success
      end

      should "render a completed file upload for the uploader" do
        upload = create(:completed_file_upload, uploader: @user)
        get_auth upload_path(upload), @user

        assert_response :success
      end

      should "render a failed upload" do
        upload = create(:upload, uploader: @user, status: "error", error: "Not an image or video")
        get_auth upload_path(upload), @user

        assert_response :success
      end

      should "render a pending upload" do
        upload = create(:upload, uploader: @user, status: "pending", source: "https://www.google.com")
        get_auth upload_path(upload), @user

        assert_response :success
      end

      should "render a processing upload" do
        upload = create(:upload, uploader: @user, status: "processing")
        get_auth upload_path(upload), @user

        assert_response :success
      end

      should "redirect a completed upload to the original post if it's a duplicate of an existing post" do
        @upload = create(:completed_file_upload, uploader: @user)
        @post = create(:post, md5: @upload.media_assets.first.md5, media_asset: @upload.media_assets.first)
        get_auth upload_path(@upload), @user

        assert_redirected_to @post
      end

      should "prefill the upload form with the URL parameters" do
        upload = create(:completed_source_upload, uploader: @user)
        get_auth upload_path(upload, post: { rating: "s" }), @user

        assert_response :success
        assert_select "#post_rating_s[checked]"
      end
    end

    context "create action" do
      should "fail if not given a file or a source" do
        assert_no_difference("Upload.count") do
          post_auth uploads_path(format: :json), @user

          assert_response 422
          assert_equal(["No file or source given"], response.parsed_body.dig("errors", "base"))
        end
      end

      should "fail if given both a file and source" do
        assert_no_difference("Upload.count") do
          file = Rack::Test::UploadedFile.new("test/files/test.jpg")
          source = "https://files.catbox.moe/om3tcw.webm"
          post_auth uploads_path(format: :json), @user, params: { upload: { files: { "0" => file }, source: source }}
        end

        assert_response 422
        assert_equal(["Can't give both a file and a source"], response.parsed_body.dig("errors", "base"))
      end

      should "fail if given an unsupported filetype" do
        file = Rack::Test::UploadedFile.new("test/files/ugoira.json")
        post_auth uploads_path(format: :json), @user, params: { upload: { files: { "0" => file } }}

        assert_response 201
        assert_match("File is not an image or video", Upload.last.error)
      end

      context "for a file larger than the file size limit" do
        setup do
          skip "flaky test"
          Danbooru.config.stubs(:max_file_size).returns(1.kilobyte)
        end

        should "fail for a direct file upload" do
          create_upload!("test/files/test.jpg", user: @user)

          assert_response 201
          assert_match("File size too large", Upload.last.error)
        end

        should "fail for a source upload with a Content-Length header" do
          create_upload!("https://nghttp2.org/httpbin/bytes/2000", user: @user)

          assert_response 201
          assert_match("File size too large", Upload.last.error)
        end

        should "fail for a source upload without a Content-Length header" do
          create_upload!("https://nghttp2.org/httpbin/stream-bytes/2000", user: @user)

          assert_response 201
          assert_match("File size too large", Upload.last.error)
        end
      end

      context "for a corrupted file" do
        should "fail for a corrupted jpeg" do
          create_upload!("test/files/test-corrupt.jpg", user: @user)
          assert_match("corrupt", Upload.last.error)
        end

        should "fail for a corrupted gif" do
          create_upload!("test/files/test-corrupt.gif", user: @user)
          assert_match("corrupt", Upload.last.error)
        end

        # https://schaik.com/pngsuite/pngsuite_xxx_png.html
        should "fail for a corrupted png" do
          create_upload!("test/files/test-corrupt.png", user: @user)
          assert_match("corrupt", Upload.last.error)
        end

        should "fail for a corrupted mp4" do
          create_upload!("test/files/mp4/test-corrupt.mp4", user: @user)
          assert_match("corrupt", Upload.last.error)
        end
      end

      context "for an unsupported WebP file" do
        should "fail for an animated WebP" do
          create_upload!("test/files/webp/nyancat.webp", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end
      end

      context "for an unsupported AVIF file" do
        should "fail for a grid image" do
          create_upload!("test/files/avif/Image grid example.avif", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for a cropped image" do
          create_upload!("test/files/avif/kimono.crop.avif", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for a rotated image" do
          create_upload!("test/files/avif/kimono.rotate90.avif", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for an image sequence" do
          create_upload!("test/files/avif/sequence-with-pitm.avif", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for a still image with an auxiliary image sequence" do
          create_upload!("test/files/avif/sequence-with-pitm-avif-major.avif", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end
      end

      context "for an unsupported video file" do
        should "fail for a .mkv file" do
          create_upload!("test/files/webm/test-512x512.mkv", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for a .mp4 file encoded with h265" do
          create_upload!("test/files/mp4/test-300x300-h265.mp4", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for a .mp4 file encoded with av1" do
          create_upload!("test/files/mp4/test-300x300-av1.mp4", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for a 10-bit color .mp4 file encoded with av1" do
          create_upload!("test/files/mp4/test-yuv420p10le-av1.mp4", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for a 10-bit color .mp4 file encoded with h264" do
          create_upload!("test/files/mp4/test-yuv420p10le-h264.mp4", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for a 10-bit color .mp4 file encoded with vp9" do
          create_upload!("test/files/mp4/test-yuv420p10le-vp9.mp4", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for a 4:4:4 subsampled .mp4 file" do
          create_upload!("test/files/mp4/test-300x300-yuv444p-h264.mp4", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end

        should "fail for a 10-bit color .webm file encoded with vp9" do
          create_upload!("test/files/webm/test-yuv420p10le-vp9.webm", user: @user)
          assert_match("File type is not supported", Upload.last.error)
        end
      end

      context "for a video longer than the video length limit" do
        should "fail for a regular user" do
          create_upload!("https://cdn.donmai.us/original/63/cb/63cb09f2526ef3ac14f11c011516ad9b.webm", user: @user)

          assert_response 201
          assert_match("Duration must be less than", Upload.last.error)
        end
      end

      context "for a video longer than the video length limit" do
        should "work for an admin" do
          create_upload!("https://cdn.donmai.us/original/63/cb/63cb09f2526ef3ac14f11c011516ad9b.webm", user: create(:admin_user))

          assert_response 201
          assert_equal("completed", Upload.last.status)
        end
      end

      context "for an unsupported archive type" do
        should "fail for a .tar file" do
          create_upload!("test/files/archive/ugoira.tar", user: @user)
          assert_match("File is not an image or video", Upload.last.error)
        end

        should "fail for a .tar.gz file" do
          create_upload!("test/files/archive/ugoira.tar.gz", user: @user)
          assert_match("File is not an image or video", Upload.last.error)
        end

        should "fail for an archive containing more than 100 files" do
          create_upload!("test/files/archive/bomb-10k-files.7z", user: @user)
          assert_response 422
          assert_match("'bomb-10k-files.7z' contains too many files (max 100 files per upload)", response.parsed_body.dig("errors", "base", 0))
        end

        should "fail for a decompression bomb" do
          create_upload!("test/files/archive/bomb-1-1G.rar", user: @user)
          assert_response 422
          assert_match("'bomb-1-1G.rar' is too large (uncompressed size: 1000 MB; max size: 100 MB)", response.parsed_body.dig("errors", "base", 0))
        end

        should "fail for an archive containing absolute paths" do
          create_upload!("test/files/archive/absolute-path.7z", user: @user)
          assert_response 422
          assert_match("'/tmp/foo/foo.txt' in 'absolute-path.7z' can't start with '/'", response.parsed_body.dig("errors", "base", 0))
        end

        should "fail for an archive containing '..' paths" do
          create_upload!("test/files/archive/zip-slip.zip", user: @user)
          assert_response 422
          assert_match(/'.*' in 'zip-slip\.zip' can't contain '\.\.' components/, response.parsed_body.dig("errors", "base", 0))
        end

        should "fail for an archive containing symlinks" do
          create_upload!("test/files/archive/symlink.zip", user: @user)
          assert_response 422
          assert_match("'passwd' in 'symlink.zip' isn't a regular file", response.parsed_body.dig("errors", "base", 0))
        end
      end

      context "when re-uploading a media asset stuck in the 'processing' state" do
        should "mark the asset as failed" do
          asset = create(:media_asset, file: File.open("test/files/test.jpg"), status: "processing")
          create_upload!("test/files/test.jpg", user: @user)

          upload = Upload.last
          assert_match("Upload failed, try again", upload.reload.error)
          assert_equal("failed", asset.reload.status)
        end
      end

      context "for a source that doesn't contain any images" do
        should "fail" do
          create_upload!("https://twitter.com/danboorubot/status/923612084616577024", user: @user)

          assert_response 201
          assert_equal(true, Upload.last.is_errored?)
          assert_match("doesn't contain any images", Upload.last.error)
        end
      end

      should "work for a source URL containing unicode characters" do
        source = "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg?one=東方&two=a%20b"

        upload = assert_successful_upload(source, user: @user)
        assert_equal(source, upload.source)
      end

      should "save the AI tags" do
        mock_autotagger_evaluate({ "1girl": 0.5 })
        upload = assert_successful_upload("test/files/test.jpg")

        assert_equal(1, upload.media_assets.first.ai_tags.count)
      end

      should "save the EXIF metadata" do
        upload = assert_successful_upload("test/files/test.jpg")

        assert_equal(true, upload.media_assets.first.media_metadata.present?)
      end

      context "uploading an AVIF file" do
        should "generate thumbnails" do
          upload = assert_successful_upload("test/files/avif/paris_icc_exif_xmp.avif", user: @user)
          media_asset = upload.media_assets.first

          full_variant = media_asset.variant(:full).open_file
          assert_equal([403, 302], full_variant.dimensions)
          assert_equal(:jpg, full_variant.file_ext)

          assert_nil(media_asset.variant(:sample))
        end
      end

      context "uploading a WebP file" do
        should "generate thumbnails" do
          upload = assert_successful_upload("test/files/webp/fjord.webp", user: @user)
          media_asset = upload.media_assets.first

          full_variant = media_asset.variant(:full).open_file
          assert_equal([550, 368], full_variant.dimensions)
          assert_equal(:jpg, full_variant.file_ext)

          assert_nil(media_asset.variant(:sample))
        end
      end

      context "uploading a file from your computer" do
        should_upload_successfully("test/files/test.jpg")
        should_upload_successfully("test/files/test.png")
        should_upload_successfully("test/files/test-static-32x32.gif")
        should_upload_successfully("test/files/test-animated-86x52.gif")
        should_upload_successfully("test/files/mp4/test-300x300.mp4")
        should_upload_successfully("test/files/mp4/test-300x300-vp9.mp4")
        should_upload_successfully("test/files/mp4/test-300x300-yuvj420p-h264.mp4")
        should_upload_successfully("test/files/mp4/test-300x300-iso4.mp4")
        should_upload_successfully("test/files/mp4/test-audio.mp4")
        should_upload_successfully("test/files/mp4/test-audio.m4v")
        should_upload_successfully("test/files/mp4/test-iso5.mp4")
        should_upload_successfully("test/files/webm/test-512x512.webm")
        should_upload_successfully("test/files/webm/test-gbrp-vp9.webm")
        # should_upload_successfully("test/files/compressed.swf")

        should_upload_successfully("test/files/avif/fox.profile0.8bpc.yuv420.monochrome.avif")
        should_upload_successfully("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv420_limited_qp40.avif")
        should_upload_successfully("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv444_full_qp40.avif")
        should_upload_successfully("test/files/avif/paris_icc_exif_xmp.avif")
        should_upload_successfully("test/files/avif/tiger_3layer_1res.avif")

        should_upload_successfully("test/files/webp/test.webp")
        should_upload_successfully("test/files/webp/fjord.webp")
        should_upload_successfully("test/files/webp/2_webp_a.webp")
        should_upload_successfully("test/files/webp/2_webp_ll.webp")
        should_upload_successfully("test/files/webp/Exif2.webp")
        should_upload_successfully("test/files/webp/lossless1.webp")
        should_upload_successfully("test/files/webp/lossy_alpha1.webp")
      end

      context "uploading a .zip file from your computer" do
        should "work" do
          upload = assert_successful_upload("test/files/archive/ugoira.zip", user: @user)

          assert_equal(5, upload.media_asset_count)
          assert_equal(5, upload.upload_media_assets.size)
          assert_equal("file://ugoira.zip/000000.jpg", upload.upload_media_assets[0].source_url)
        end

        should "upload the files in filename order" do
          upload = assert_successful_upload("test/files/archive/out-of-order.zip", user: @user)

          assert_equal(6, upload.media_asset_count)
          assert_equal(6, upload.upload_media_assets.size)
          assert_equal("file://out-of-order.zip/9/9.gif", upload.upload_media_assets[0].source_url)
          assert_equal("file://out-of-order.zip/9/10.gif", upload.upload_media_assets[1].source_url)
          assert_equal("file://out-of-order.zip/9/11.gif", upload.upload_media_assets[2].source_url)
          assert_equal("file://out-of-order.zip/10/9.gif", upload.upload_media_assets[3].source_url)
          assert_equal("file://out-of-order.zip/10/10.gif", upload.upload_media_assets[4].source_url)
          assert_equal("file://out-of-order.zip/10/11.gif", upload.upload_media_assets[5].source_url)
        end
      end

      context "uploading a .rar file from your computer" do
        should "work" do
          upload = assert_successful_upload("test/files/archive/ugoira.rar", user: @user)

          assert_equal(5, upload.media_asset_count)
          assert_equal(5, upload.upload_media_assets.size)
          assert_equal("file://ugoira.rar/000000.jpg", upload.upload_media_assets[0].source_url)
        end
      end

      context "uploading a .7z file from your computer" do
        should "work" do
          upload = assert_successful_upload("test/files/archive/ugoira.7z", user: @user)

          assert_equal(5, upload.media_asset_count)
          assert_equal(5, upload.upload_media_assets.size)
          assert_equal("file://ugoira.7z/000000.jpg", upload.upload_media_assets[0].source_url)
        end
      end

      context "uploading multiple files from your computer" do
        should "work" do
          files = {
            "0" => Rack::Test::UploadedFile.new("test/files/test.jpg"),
            "1" => Rack::Test::UploadedFile.new("test/files/test.png"),
            "2" => Rack::Test::UploadedFile.new("test/files/test.gif"),
          }

          post_auth uploads_path(format: :json), @user, params: { upload: { files: files }}

          upload = Upload.last
          assert_response 201
          assert_equal("", upload.error.to_s)
          assert_equal("completed", upload.status)
          assert_equal(3, upload.media_asset_count)
        end
      end

      context "uploading a ugoira" do
        should "work" do
          upload = assert_successful_upload("https://www.pixiv.net/en/artworks/45982180", user: @user)

          assert_equal([60] * 70, upload.media_assets.first.metadata["Ugoira:FrameDelays"])
          assert_equal(:webm, upload.media_assets.first.variant(:sample).open_file.file_ext)
        end
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

        should_upload_successfully("https://gelbooru.com/index.php?page=post&s=view&id=7798121")
        should_upload_successfully("https://safebooru.org/index.php?page=post&s=view&id=4189916")
        should_upload_successfully("https://tbib.org/index.php?page=post&s=view&id=11480218")
        should_upload_successfully("https://rule34.xxx/index.php?page=post&s=view&id=6961597")
        should_upload_successfully("https://rule34.us/index.php?r=posts/view&id=6204967")

        should_upload_successfully("https://boards.4channel.org/vt/thread/1#p1")

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
        should_upload_successfully("https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg")

        should_upload_successfully("https://pawoo.net/web/statuses/1202176") if Danbooru.config.pawoo_access_token.present? # XXX
        should_upload_successfully("https://img.pawoo.net/media_attachments/files/000/128/953/original/4c0a06087b03343f.png") if Danbooru.config.pawoo_access_token.present? # XXX

        should_upload_successfully("https://baraag.net/@danbooru/107866090743238456")
        should_upload_successfully("https://baraag.net/system/media_attachments/files/107/866/084/749/942/932/original/a9e0f553e332f303.mp4")

        should_upload_successfully("https://www.pixiv.net/en/artworks/64476642")
        should_upload_successfully("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
        should_upload_successfully("https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg")

        should_upload_successfully("https://sketch.pixiv.net/items/1086346113447960710")

        should_upload_successfully("https://noizave.tumblr.com/post/162206271767")
        should_upload_successfully("https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png")

        should_upload_successfully("https://twitter.com/noizave/status/875768175136317440")
        should_upload_successfully("https://pbs.twimg.com/media/DCdZ_FhUIAAYKFN?format=jpg&name=medium")
        should_upload_successfully("https://pbs.twimg.com/profile_banners/2371694594/1581832507/1500x500")
        should_upload_successfully("https://twitter.com/zeth_total/status/1355597580814585856")
        should_upload_successfully("https://video.twimg.com/tweet_video/EWHWVrmVcAAp4Vw.mp4")

        should_upload_successfully("https://www.weibo.com/5501756072/J2UNKfbqV")
        should_upload_successfully("https://wx1.sinaimg.cn/mw690/0060kO5aly1gezsyt5xvhj30ok0sgtc9.jpg")

        should_upload_successfully("https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg")
        should_upload_successfully("https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg")
        should_upload_successfully("https://www.newgrounds.com/art/view/puddbytes/costanza-at-bat")

        should_upload_successfully("https://kmyama.fanbox.cc/posts/104708")
        should_upload_successfully("https://downloads.fanbox.cc/images/post/104708/wsF73EC5Fq0CIK84W0LGYk2p.jpeg")

        should_upload_successfully("https://foundation.app/@mochiiimo/~/97376")
        should_upload_successfully("https://foundation.app/@mochiiimo/foundation/97376")
        should_upload_successfully("https://foundation.app/@KILLERGF/kgfgen/4")

        should_upload_successfully("https://skeb.jp/@kokuzou593/works/45")
        should_upload_successfully("https://skeb.jp/@LambOic029/works/146")
        should_upload_successfully("https://skeb.imgix.net/uploads/origins/307941e9-dbe0-4e4b-93d4-94accdaff9a0?bg=%23fff&auto=format&w=800&s=e0ddfb1fa0d9f23797b338598aae78fa")

        should_upload_successfully("https://www.plurk.com/p/omc64y")
        should_upload_successfully("https://www.plurk.com/p/om6zv4")

        should_upload_successfully("https://gengar563.lofter.com/post/1e82da8c_1c98dae1b")

        should_upload_successfully("https://c.fantia.jp/uploads/post/file/1070093/16faf0b1-58d8-4aac-9e86-b243063eaaf1.jpeg")
        should_upload_successfully("https://fantia.jp/posts/1132267")
        should_upload_successfully("https://fantia.jp/products/249638")

        should_upload_successfully("http://wwwew.web.fc2.com/e/405.jpg")

        should_upload_successfully("http://www.tinami.com/view/1087268")

        should_upload_successfully("https://booth.pximg.net/4ee2c0d9-41fa-4a0e-a30f-1bc9e15d4e5b/i/2586180/331b7c5f-7614-4772-aae2-cb979ad44a6b.png")

        should_upload_successfully("https://picdig.net/ema/projects/9d99151f-6d3e-4084-9cc0-082d386122ca")

        should_upload_successfully("https://enty.jp/posts/141598")

        should_upload_successfully("https://arca.live/b/arknights/66031722")

        should_upload_successfully("https://imgur.com/AOeREEF")

        should_upload_successfully("https://poipiku.com/583/2867587.html")

        should_upload_successfully("https://medibang.com/picture/4b2112261505098280008769655/")

        should_upload_successfully("https://movw2000.gumroad.com/l/zbslv")
        should_upload_successfully("https://movw2000.gumroad.com/p/new-product-b072093e-e628-4a92-9740-e9b4564d9901")
      end
    end
  end
end
