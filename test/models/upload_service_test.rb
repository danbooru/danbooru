require 'test_helper'

class UploadServiceTest < ActiveSupport::TestCase
  UGOIRA_CONTEXT = {
    "ugoira" => {
      "frame_data" => [
        {"file" => "000000.jpg", "delay" => 200},
        {"file" => "000001.jpg", "delay" => 200},
        {"file" => "000002.jpg", "delay" => 200},
        {"file" => "000003.jpg", "delay" => 200},
        {"file" => "000004.jpg", "delay" => 250}
      ],
      "content_type" => "image/jpeg"
    }
  }.freeze

  context "::Utils" do
    subject { UploadService::Utils }

    context "#download_from_source" do
      setup do
        @jpeg = "https://upload.wikimedia.org/wikipedia/commons/c/c5/Moraine_Lake_17092005.jpg"
        @ugoira = "https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip"
      end

      should "work on a jpeg" do
        file = subject.download_from_source(@jpeg) do |context|
          assert_not_nil(context[:downloaded_source])
          assert_not_nil(context[:source])
        end

        assert_operator(File.size(file.path), :>, 0)
        file.close
      end

      should "work on an ugoira url" do
        file = subject.download_from_source(@ugoira, referer_url: "https://www.pixiv.net") do |context|
          assert_not_nil(context[:downloaded_source])
          assert_not_nil(context[:source])
          assert_not_nil(context[:ugoira])
        end

        assert_operator(File.size(file.path), :>, 0)
        file.close
      end
    end

    context ".calculate_ugoira_dimensions" do
      context "for a valid ugoira file" do
        setup do
          @path = "test/files/valid_ugoira.zip"
        end

        should "extract the dimensions" do
          w, h = subject.calculate_ugoira_dimensions(@path)
          assert_operator(w, :>, 0)
          assert_operator(h, :>, 0)
        end
      end

      context "for an invalid ugoira file" do
        setup do
          @path = "test/files/invalid_ugoira.zip"
        end

        should "raise an error" do
          assert_raises(ImageSpec::Error) do
            subject.calculate_ugoira_dimensions(@path)
          end
        end
      end
    end

    context ".calculate_dimensions" do
      context "for an ugoira" do
        setup do
          @file = File.open("test/files/valid_ugoira.zip", "rb")
          @upload = mock()
          @upload.stubs(:is_video?).returns(false)
          @upload.stubs(:is_ugoira?).returns(true)
        end

        teardown do
          @file.close
        end

        should "return the dimensions" do
          subject.expects(:calculate_ugoira_dimensions).once.returns([60, 60])
          subject.calculate_dimensions(@upload, @file) do |w, h|
            assert_operator(w, :>, 0)
            assert_operator(h, :>, 0)
          end
        end
      end

      context "for a video" do
        setup do
          @file = File.open("test/files/test-300x300.mp4", "rb")
          @upload = mock()
          @upload.stubs(:is_video?).returns(true)
        end

        teardown do
          @file.close
        end

        should "return the dimensions" do
          subject.calculate_dimensions(@upload, @file) do |w, h|
            assert_operator(w, :>, 0)
            assert_operator(h, :>, 0)
          end
        end
      end

      context "for an image" do 
        setup do
          @file = File.open("test/files/test.jpg", "rb")
          @upload = mock()
          @upload.stubs(:is_video?).returns(false)
          @upload.stubs(:is_ugoira?).returns(false)
        end

        teardown do
          @file.close
        end

        should "find the dimensions" do
          subject.calculate_dimensions(@upload, @file) do |w, h|
            assert_operator(w, :>, 0)
            assert_operator(h, :>, 0)
          end
        end
      end
    end

    context ".process_file" do
      setup do
        @upload = FactoryBot.build(:jpg_upload)
        @file = @upload.file
      end

      should "run" do
        subject.expects(:distribute_files).times(3)
        subject.process_file(@upload, @file)
        assert_equal("jpg", @upload.file_ext)
        assert_equal(28086, @upload.file_size)
        assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @upload.md5)
        assert_equal(335, @upload.image_height)
        assert_equal(500, @upload.image_width)
      end
    end

    context ".generate_resizes" do
      context "for an ugoira" do
        setup do
          context = UGOIRA_CONTEXT
          @file = File.open("test/fixtures/ugoira.zip", "rb")
          @upload = mock()
          @upload.stubs(:is_video?).returns(false)
          @upload.stubs(:is_ugoira?).returns(true)
          @upload.stubs(:context).returns(context)
        end

        should "generate a preview and a video" do
          preview, sample = subject.generate_resizes(@file, @upload)
          assert_operator(File.size(preview.path), :>, 0)
          assert_operator(File.size(sample.path), :>, 0)
          preview.close
          preview.unlink
          sample.close
          sample.unlink
        end
      end

      context "for a video" do
        teardown do
          @file.close
        end

        context "for an mp4" do
          setup do
            @file = File.open("test/files/test-300x300.mp4", "rb")
            @upload = mock()
            @upload.stubs(:is_video?).returns(true)
            @upload.stubs(:is_ugoira?).returns(false)
          end

          should "generate a video" do
            preview, sample = subject.generate_resizes(@file, @upload)
            assert_operator(File.size(preview.path), :>, 0)
            preview.close
            preview.unlink
          end
        end

        context "for a webm" do
          setup do
            @file = File.open("test/files/test-512x512.webm", "rb")
            @upload = mock()
            @upload.stubs(:is_video?).returns(true)
            @upload.stubs(:is_ugoira?).returns(false)
          end

          should "generate a video" do
            preview, sample = subject.generate_resizes(@file, @upload)
            assert_operator(File.size(preview.path), :>, 0)
            preview.close
            preview.unlink
          end
        end
      end

      context "for an image" do
        teardown do
          @file.close
        end

        setup do
          @upload = mock()
          @upload.stubs(:is_video?).returns(false)
          @upload.stubs(:is_ugoira?).returns(false)
          @upload.stubs(:is_image?).returns(true)
          @upload.stubs(:image_width).returns(1200)
          @upload.stubs(:image_height).returns(200)
        end

        context "for a jpeg" do
          setup do
            @file = File.open("test/files/test.jpg", "rb")
          end

          should "generate a preview" do
            preview, sample = subject.generate_resizes(@file, @upload)
            assert_operator(File.size(preview.path), :>, 0)
            assert_operator(File.size(sample.path), :>, 0)
            preview.close
            preview.unlink
            sample.close
            sample.unlink
          end
        end

        context "for a png" do
          setup do
            @file = File.open("test/files/test.png", "rb")
          end

          should "generate a preview" do
            preview, sample = subject.generate_resizes(@file, @upload)
            assert_operator(File.size(preview.path), :>, 0)
            assert_operator(File.size(sample.path), :>, 0)
            preview.close
            preview.unlink
            sample.close
            sample.unlink
          end
        end

        context "for a gif" do
          setup do
            @file = File.open("test/files/test.png", "rb")
          end

          should "generate a preview" do
            preview, sample = subject.generate_resizes(@file, @upload)
            assert_operator(File.size(preview.path), :>, 0)
            assert_operator(File.size(sample.path), :>, 0)
            preview.close
            preview.unlink
            sample.close
            sample.unlink
          end
        end
      end
    end

    context ".generate_video_preview_for" do
      context "for an mp4" do
        setup do
          @path = "test/files/test-300x300.mp4"
          @video = FFMPEG::Movie.new(@path)
        end

        should "generate a video" do
          sample = subject.generate_video_preview_for(@video, 100, 100)
          assert_operator(File.size(sample.path), :>, 0)
          sample.close
          sample.unlink
        end
      end

      context "for a webm" do
        setup do
          @path = "test/files/test-512x512.webm"
          @video = FFMPEG::Movie.new(@path)
        end

        should "generate a video" do
          sample = subject.generate_video_preview_for(@video, 100, 100)
          assert_operator(File.size(sample.path), :>, 0)
          sample.close
          sample.unlink
        end
      end
    end
  end

  context "::Preprocessor" do
    subject { UploadService::Preprocessor }

    context "#start!" do
      setup do
        CurrentUser.user = travel_to(1.month.ago) do
          FactoryBot.create(:user)
        end
        CurrentUser.ip_addr = "127.0.0.1"
        @jpeg = "https://upload.wikimedia.org/wikipedia/commons/c/c5/Moraine_Lake_17092005.jpg"
        @ugoira = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364"
        @video = "https://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4"
      end

      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      should "work for a jpeg" do
        @service = subject.new(source: @jpeg)
        @upload = @service.start!(CurrentUser.id)
        assert_equal("preprocessed", @upload.status)
        assert_not_nil(@upload.md5)
        assert_equal("jpg", @upload.file_ext)
        assert_operator(@upload.file_size, :>, 0)
        assert_not_nil(@upload.source)
        assert(File.exists?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :original)))
        assert(File.exists?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :large)))
        assert(File.exists?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :preview)))
      end

      should "work for an ugoira" do
        @service = subject.new(source: @ugoira)
        @upload = @service.start!(CurrentUser.id)
        assert_equal("preprocessed", @upload.status)
        assert_not_nil(@upload.md5)
        assert_equal("zip", @upload.file_ext)
        assert_operator(@upload.file_size, :>, 0)
        assert_not_nil(@upload.source)
        assert(File.exists?(Danbooru.config.storage_manager.file_path(@upload.md5, "zip", :original)))
        assert(File.exists?(Danbooru.config.storage_manager.file_path(@upload.md5, "zip", :large)))
      end

      should "work for a video" do
        @service = subject.new(source: @video)
        @upload = @service.start!(CurrentUser.id)
        assert_equal("preprocessed", @upload.status)
        assert_not_nil(@upload.md5)
        assert_equal("mp4", @upload.file_ext)
        assert_operator(@upload.file_size, :>, 0)
        assert_not_nil(@upload.source)
        assert(File.exists?(Danbooru.config.storage_manager.file_path(@upload.md5, "mp4", :original)))
        assert(File.exists?(Danbooru.config.storage_manager.file_path(@upload.md5, "mp4", :preview)))
      end

      context "on timeout errors" do
        setup do
          HTTParty.stubs(:get).raises(Net::ReadTimeout)
        end
        
        should "leave the upload in an error state" do
          @service = subject.new(source: @video)
          @upload = @service.start!(CurrentUser.id)
          assert_match(/error:/, @upload.status)
        end
      end

    end
  end

  context "::Replacer" do
    context "for a file replacement" do
      setup do
        @new_file = upload_file("test/files/test.jpg")
        @old_file = upload_file("test/files/test.png")
        travel_to(1.month.ago) do
          @user = FactoryBot.create(:user)
        end
        as_user do
          @post = FactoryBot.create(:post, md5: Digest::MD5.hexdigest(@old_file.read))
          @old_md5 = @post.md5
          @post.stubs(:queue_delete_files)
          @replacement = FactoryBot.create(:post_replacement, post: @post, replacement_url: "", replacement_file: @new_file)
        end
      end      

      subject { UploadService::Replacer.new(post: @post, replacement: @replacement) }

      context "#process!" do
        should "create a new upload" do
          assert_difference(-> { Upload.count }) do
            as_user { subject.process! }
          end
        end

        should "create a comment" do
          assert_difference(-> { @post.comments.count }) do
            as_user { subject.process! }
            @post.reload
          end
        end

        should "not create a new post" do
          assert_difference(-> { Post.count }, 0) do
            as_user { subject.process! }
          end
        end

        should "update the post's MD5" do
          assert_changes(-> { @post.md5 }) do
            as_user { subject.process! }
            @post.reload
          end
        end

        should "preserve the old values" do
          as_user { subject.process! }
          assert_equal(1500, @replacement.image_width_was)
          assert_equal(1000, @replacement.image_height_was)
          assert_equal(2000, @replacement.file_size_was)
          assert_equal("jpg", @replacement.file_ext_was)
          assert_equal(@old_md5, @replacement.md5_was)
        end

        should "record the new values" do
          as_user { subject.process! }
          assert_equal(500, @replacement.image_width)
          assert_equal(335, @replacement.image_height)
          assert_equal(28086, @replacement.file_size)
          assert_equal("jpg", @replacement.file_ext)
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @replacement.md5)
        end

        should "correctly update the attributes" do
          as_user { subject.process! }
          assert_equal(500, @post.image_width)
          assert_equal(335, @post.image_height)
          assert_equal(28086, @post.file_size)
          assert_equal("jpg", @post.file_ext)
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @post.md5)
          assert(File.exists?(@post.file.path))
        end
      end

      context "a post with the same file" do
        should "not raise a duplicate error" do
          upload_file("test/files/test.png") do |file|
            assert_nothing_raised do
              as_user { @post.replace!(replacement_file: file, replacement_url: "") }
            end
          end
        end

        should "not queue a deletion or log a comment" do
          upload_file("test/files/test.png") do |file|
            assert_no_difference(-> { @post.comments.count }) do
              as_user { @post.replace!(replacement_file: file, replacement_url: "") }
              @post.reload
            end
          end
        end
      end
    end

    context "for a source replacement" do
      setup do
        @new_url = "https://upload.wikimedia.org/wikipedia/commons/c/c5/Moraine_Lake_17092005.jpg"
        travel_to(1.month.ago) do
          @user = FactoryBot.create(:user)
        end
        as_user do
          @post = FactoryBot.create(:post, uploader_ip_addr: "127.0.0.2")
          @post.stubs(:queue_delete_files)
          @replacement = FactoryBot.create(:post_replacement, post: @post, replacement_url: @new_url)
        end
      end

      subject { UploadService::Replacer.new(post: @post, replacement: @replacement) }

      context "when an upload with the same source already exists" do
        setup do
          @post = FactoryBot.create(:post, source: @new_url)
        end

        should "throw an error" do
          assert_raises(ActiveRecord::RecordNotUnique) do
            as_user { @post.replace!(replacement_url: @new_url) }
          end
        end
      end

      context "a post when given a final_source" do
        should "change the source to the final_source" do
          replacement_url = "http://data.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_orwwptNBCE1wsfqepo1_raw.png"
          final_source = "https://noizave.tumblr.com/post/162094447052"

          as_user { @post.replace!(replacement_url: replacement_url, final_source: final_source) }

          assert_equal(final_source, @post.source)
        end
      end

      context "a post when replaced with a HTML source" do
        should "record the image URL as the replacement URL, not the HTML source" do
          skip "Twitter key not set" unless Danbooru.config.twitter_api_key
          replacement_url = "https://twitter.com/nounproject/status/540944400767922176"
          image_url = "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig"
          as_user { @post.replace!(replacement_url: replacement_url) }

          assert_equal(image_url, @post.replacements.last.replacement_url)
        end
      end

      context "#undo!" do
        setup do
          @user = travel_to(1.month.ago) { FactoryBot.create(:user) }
          as_user do
            @post = FactoryBot.create(:post, source: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png")
            @post.stubs(:queue_delete_files)
            @post.replace!(replacement_url: "https://danbooru.donmai.us/data/preview/download.png", tags: "-tag1 tag2")
          end

          @replacement = @post.replacements.last
        end

        should "update the attributes" do
          as_user do
            subject.undo!
          end

          assert_equal("lowres tag2", @post.tag_string)
          assert_equal(272, @post.image_width)
          assert_equal(92, @post.image_height)
          assert_equal(5969, @post.file_size)
          assert_equal("png", @post.file_ext)
          assert_equal("8f9327db2597fa57d2f42b4a6c5a9855", @post.md5)
          assert_equal("8f9327db2597fa57d2f42b4a6c5a9855", Digest::MD5.file(@post.file).hexdigest)
          assert_equal("https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png", @post.source)
        end
      end

      context "#process!" do
        should "create a new upload" do
          assert_difference(-> { Upload.count }) do
            as_user { subject.process! }
          end
        end

        should "create a comment" do
          assert_difference(-> { @post.comments.count }) do
            as_user { subject.process! }
            @post.reload
          end
        end

        should "not create a new post" do
          assert_difference(-> { Post.count }, 0) do
            as_user { subject.process! }
          end
        end

        should "update the post's MD5" do
          assert_changes(-> { @post.md5 }) do
            as_user { subject.process! }
            @post.reload
          end
        end

        should "update the post's source" do
          assert_changes(-> { @post.source }, nil, from: @post.source, to: @new_url) do
            as_user { subject.process! }
            @post.reload
          end
        end

        should "not change the post status or uploader" do
          assert_no_changes(-> { {ip_addr: @post.uploader_ip_addr.to_s, uploader: @post.uploader_id, pending: @post.is_pending?} }) do
            as_user { subject.process! }
            @post.reload
          end
        end

        should "leave a system comment" do
          as_user { subject.process! }
          comment = @post.comments.last
          assert_not_nil(comment)
          assert_equal(User.system.id, comment.creator_id)
          assert_match(/replaced this post/, comment.body)
        end
      end

      context "a post with a pixiv html source" do
        setup do
          Delayed::Worker.delay_jobs = true
        end

        teardown do
          Delayed::Worker.delay_jobs = false
        end

        should "replace with the full size image" do
          begin
            as_user do
              @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
            end

            assert_equal(80, @post.image_width)
            assert_equal(82, @post.image_height)
            assert_equal(16275, @post.file_size)
            assert_equal("png", @post.file_ext)
            assert_equal("4ceadc314938bc27f3574053a3e1459a", @post.md5)
            assert_equal("4ceadc314938bc27f3574053a3e1459a", Digest::MD5.file(@post.file).hexdigest)
            assert_equal("https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png", @post.replacements.last.replacement_url)
            assert_equal("https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png", @post.source)
          rescue Net::OpenTimeout
            skip "Remote connection to Pixiv failed"
          end
        end

        should "delete the old files after thirty days" do
          begin
            @post.unstub(:queue_delete_files)
            FileUtils.expects(:rm_f).times(3)

            as_user { @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350") }

            travel_to((PostReplacement::DELETION_GRACE_PERIOD + 1).days.from_now) do
              Delayed::Worker.new.work_off
            end
          rescue Net::OpenTimeout
            skip "Remote connection to Pixiv failed"
          end
        end
      end

      context "a post that is replaced by a ugoira" do
        should "save the frame data" do
          skip "ffmpeg not installed" unless check_ffmpeg
          begin
            as_user { @post.replace!(replacement_url: "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364") }
            @post.reload

            assert_equal(80, @post.image_width)
            assert_equal(82, @post.image_height)
            assert_equal(2804, @post.file_size)
            assert_equal("zip", @post.file_ext)
            assert_equal("cad1da177ef309bf40a117c17b8eecf5", @post.md5)
            assert_equal("cad1da177ef309bf40a117c17b8eecf5", Digest::MD5.file(@post.file).hexdigest)

            assert_equal("https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip", @post.source)
            assert_equal([{"delay"=>125, "file"=>"000000.jpg"}, {"delay"=>125,"file"=>"000001.jpg"}], @post.pixiv_ugoira_frame_data.data)
          rescue Net::OpenTimeout
            skip "Remote connection to Pixiv failed"
          end
        end
      end

      context "a post that is replaced to another file then replaced back to the original file" do
        setup do
          Delayed::Worker.delay_jobs = true
        end

        teardown do
          Delayed::Worker.delay_jobs = false
        end

        should "not delete the original files" do
          begin
            FileUtils.expects(:rm_f).never

            as_user do
              @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
              @post.reload
              @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
              @post.reload
              Upload.destroy_all
              @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
            end

            assert_nothing_raised { @post.file(:original) }
            assert_nothing_raised { @post.file(:preview) }

            travel_to((PostReplacement::DELETION_GRACE_PERIOD + 1).days.from_now) do
              Delayed::Worker.new.work_off
            end

            assert_nothing_raised { @post.file(:original) }
            assert_nothing_raised { @post.file(:preview) }
          rescue Net::OpenTimeout
            skip "Remote connection to Pixiv failed"
          end
        end
      end

      context "two posts that have had their files swapped" do
        setup do
          Delayed::Worker.delay_jobs = true

          as_user do
            @post1 = FactoryBot.create(:post)
            @post2 = FactoryBot.create(:post)
          end
        end

        teardown do
          Delayed::Worker.delay_jobs = false
        end

        should "not delete the still active files" do
          # swap the images between @post1 and @post2.
          begin
            as_user do
              @post1.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
              @post2.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
              @post2.replace!(replacement_url: "https://www.google.com/intl/en_ALL/images/logo.gif")
              Upload.destroy_all
              @post1.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
              @post2.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
            end

            Timecop.travel(Time.now + PostReplacement::DELETION_GRACE_PERIOD + 1.day) do
              Delayed::Worker.new.work_off
            end

            assert_nothing_raised { @post1.file(:original) }
            assert_nothing_raised { @post2.file(:original) }
          rescue Net::OpenTimeout
            skip "Remote connection to Pixiv failed"
          end
        end
      end

      context "a post with notes" do
        setup do
          Note.any_instance.stubs(:merge_version?).returns(false)

          as_user do
            @post.update(image_width: 160, image_height: 164)
            @note = @post.notes.create(x: 80, y: 82, width: 80, height: 82, body: "test")
            @note.reload
          end
        end

        should "rescale the notes" do
          assert_equal([80, 82, 80, 82], [@note.x, @note.y, @note.width, @note.height])

          begin
            assert_difference(-> { @note.versions.count }) do
              # replacement image is 80x82, so we're downscaling by 50% (160x164 -> 80x82).
              as_user do
                @post.replace!(replacement_url: "https://upload.wikimedia.org/wikipedia/commons/c/c5/Moraine_Lake_17092005.jpg")
              end
              @note.reload
            end

            assert_equal([1024, 768, 1024, 768], [@note.x, @note.y, @note.width, @note.height])
          rescue Net::OpenTimeout
            skip "Remote connection to Pixiv failed"
          end
        end
      end
    end
  end

  context "#start!" do
    subject { UploadService }

    setup do
      @source = "https://upload.wikimedia.org/wikipedia/commons/c/c5/Moraine_Lake_17092005.jpg"
      CurrentUser.user = travel_to(1.month.ago) do
        FactoryBot.create(:user)
      end
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "automatic tagging" do
      setup do
        @build_service = ->(file) { subject.new(file: file)}
      end

      should "tag animated png files" do
        service = @build_service.call(upload_file("test/files/apng/normal_apng.png"))
        upload = service.start!
        assert_match(/animated_png/, upload.tag_string)
      end

      should "tag animated gif files" do
        service = @build_service.call(upload_file("test/files/test-animated-86x52.gif"))
        upload = service.start!
        assert_match(/animated_gif/, upload.tag_string)
      end

      should "not tag static gif files" do
        service = @build_service.call(upload_file("test/files/test-static-32x32.gif"))
        upload = service.start!
        assert_no_match(/animated_gif/, upload.tag_string)
      end
    end

    context "that is too large" do
      setup do
        Danbooru.config.stubs(:max_image_resolution).returns(31*31)
      end

      should "should fail validation" do
        service = subject.new(file: upload_file("test/files/test-static-32x32.gif"))
        upload = service.start!
        assert_match(/image resolution is too large/, upload.status)
      end
    end

    context "with a preprocessing predecessor" do
      setup do
        @predecessor = FactoryBot.create(:source_upload, status: "preprocessing", source: @source, image_height: 0, image_width: 0, file_ext: "jpg")
        Delayed::Worker.delay_jobs = true
      end

      teardown do
        Delayed::Worker.delay_jobs = false
      end

      should "schedule a job later" do
        service = subject.new(source: @source)

        assert_difference(-> { Delayed::Job.count }) do
          predecessor = service.start!
          assert_equal(@predecessor, predecessor)
        end
      end
    end

    context "with a preprocessed predecessor" do
      setup do
        @predecessor = FactoryBot.create(:source_upload, status: "preprocessed", source: @source, image_height: 0, image_width: 0, file_size: 1, md5: 'blank', file_ext: "jpg")
        @tags = 'hello world'
      end

      should "update the predecessor" do
        service = subject.new(source: @source, tag_string: @tags)

        predecessor = service.start!
        assert_equal(@predecessor, predecessor)
        assert_equal(@tags, predecessor.tag_string.strip)
      end
    end

    context "with no predecessor" do
      should "create an upload" do
        service = subject.new(source: @source)

        assert_difference(-> { Upload.count }) do
          service.start!
        end
      end
    end
  end

  context "#create_post_from_upload" do
    subject { UploadService }

    setup do
      CurrentUser.user = travel_to(1.month.ago) do
        FactoryBot.create(:user)
      end
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "for an ugoira" do
      setup do
        @upload = FactoryBot.create(:ugoira_upload, file_size: 1000, md5: "12345", file_ext: "jpg", image_width: 100, image_height: 100, context: UGOIRA_CONTEXT)
      end

      should "create a post" do
        assert_difference(-> { PixivUgoiraFrameData.count }) do
          post = subject.new({}).create_post_from_upload(@upload)
          assert_equal([], post.errors.full_messages)
          assert_not_nil(post.id)
        end
      end
    end

    context "for an image" do
      setup do
        @upload = FactoryBot.create(:source_upload, file_size: 1000, md5: "12345", file_ext: "jpg", image_width: 100, image_height: 100)
      end

      should "create a commentary record" do
        assert_difference(-> { ArtistCommentary.count }) do
          subject.new({include_artist_commentary: true, artist_commentary_title: "blah", artist_commentary_desc: "blah"}).create_post_from_upload(@upload)
        end
      end

      should "create a post" do
        post = subject.new({}).create_post_from_upload(@upload)
        assert_equal([], post.errors.full_messages)
        assert_not_nil(post.id)
      end
    end

  end
end
