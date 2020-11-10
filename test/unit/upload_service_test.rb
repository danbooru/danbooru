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
  }

  context "::Utils" do
    context "#get_file_for_upload" do
      context "for a non-source site" do
        setup do
          @source = "https://upload.wikimedia.org/wikipedia/commons/c/c5/Moraine_Lake_17092005.jpg"
          @upload = Upload.new
          @upload.source = @source
        end

        should "work on a jpeg" do
          file = UploadService::Utils.get_file_for_upload(@upload)
          assert_operator(File.size(file.path), :>, 0)
          file.close
        end
      end

      context "for a pixiv" do
        setup do
          @source = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350"
          @upload = Upload.new
          @upload.source = @source
        end

        should "work on an ugoira url" do
          begin
            file = UploadService::Utils.get_file_for_upload(@upload)
            assert_operator(File.size(file.path), :>, 0)
            file.close
          end
        end
      end

      context "for a pixiv ugoira" do
        setup do
          @source = "https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip"
          @referer = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364"
          @upload = Upload.new
          @upload.source = @source
          @upload.referer_url = @referer
        end

        should "work on an ugoira url" do
          file = UploadService::Utils.get_file_for_upload(@upload)

          assert_not_nil(@upload.context["ugoira"])
          assert_operator(File.size(file.path), :>, 0)

          file.close
        end
      end
    end

    context ".process_file" do
      setup do
        @upload = FactoryBot.build(:jpg_upload)
      end

      context "with an original_post_id" do
        should "run" do
          UploadService::Utils.expects(:distribute_files).times(3)
          UploadService::Utils.process_file(@upload, @upload.file.tempfile, original_post_id: 12345)
        end
      end

      should "run" do
        UploadService::Utils.expects(:distribute_files).times(3)
        UploadService::Utils.process_file(@upload, @upload.file.tempfile)
        assert_equal("jpg", @upload.file_ext)
        assert_equal(28086, @upload.file_size)
        assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @upload.md5)
        assert_equal(335, @upload.image_height)
        assert_equal(500, @upload.image_width)
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
      end

      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      context "for twitter" do
        setup do
          @source = "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:large"
          @ref = "https://twitter.com/nounproject/status/540944400767922176"
        end

        should "download the file" do
          @service = UploadService::Preprocessor.new(source: @source, referer_url: @ref)
          @upload = @service.start!
          assert_equal("preprocessed", @upload.status)
          assert_equal(9800, @upload.file_size)
          assert_equal("png", @upload.file_ext)
          assert_equal("f5fe24f3a3a13885285f6627e04feec9", @upload.md5)
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "png", :original)))
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "png", :preview)))
        end
      end

      context "for pixiv" do
        setup do
          @source = "https://i.pximg.net/img-original/img/2014/10/29/09/27/19/46785915_p0.jpg"
          @ref = "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=46785915"
        end

        should "download the file" do
          @service = UploadService::Preprocessor.new(source: @source, referer_url: @ref)
          @upload = @service.start!

          assert_equal("preprocessed", @upload.status)
          assert_equal(317733, @upload.file_size)
          assert_equal("jpg", @upload.file_ext)
          assert_equal("4c71da5638b897aa6da1150e742e2982", @upload.md5)
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :original)))
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :preview)))
        end
      end

      context "for pixiv ugoira" do
        setup do
          @source = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364"
        end

        should "download the file" do
          skip unless MediaFile::Ugoira.videos_enabled?

          @service = UploadService::Preprocessor.new(source: @source)
          @upload = @service.start!

          assert_equal("preprocessed", @upload.status)
          assert_equal(2804, @upload.file_size)
          assert_equal("zip", @upload.file_ext)
          assert_equal("cad1da177ef309bf40a117c17b8eecf5", @upload.md5)
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "zip", :original)))
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "zip", :large)))
        end
      end

      context "for null" do
        setup do
          @source = "https://cdn.donmai.us/original/93/f4/93f4dd66ef1eb11a89e56d31f9adc8d0.jpg"
        end

        should "download the file" do
          @service = UploadService::Preprocessor.new(source: @source)
          @upload = @service.start!

          assert_equal("preprocessed", @upload.status)
          assert_equal(181309, @upload.file_size)
          assert_equal("jpg", @upload.file_ext)
          assert_equal("93f4dd66ef1eb11a89e56d31f9adc8d0", @upload.md5)
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :original)))
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :large)))
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :preview)))
        end
      end

      context "for a video" do
        setup do
          @source = "https://cdn.donmai.us/original/b7/cb/b7cb80092be273771510952812380fa2.mp4"
        end

        should "work for a video" do
          @service = UploadService::Preprocessor.new(source: @source)
          @upload = @service.start!
          assert_equal("preprocessed", @upload.status)
          assert_not_nil(@upload.md5)
          assert_equal("mp4", @upload.file_ext)
          assert_operator(@upload.file_size, :>, 0)
          assert_not_nil(@upload.source)
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "mp4", :original)))
          assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "mp4", :preview)))
        end
      end

      context "on timeout errors" do
        setup do
          @source = "https://cdn.donmai.us/original/93/f4/93f4dd66ef1eb11a89e56d31f9adc8d0.jpg"
          Danbooru::Http.any_instance.stubs(:get).raises(HTTP::TimeoutError)
        end

        should "leave the upload in an error state" do
          @service = UploadService::Preprocessor.new(source: @source)
          @upload = @service.start!
          assert_match(/error:/, @upload.status)
        end
      end

      context "for an invalid content type" do
        should "fail" do
          upload = UploadService::Preprocessor.new(source: "http://www.example.com").start!
          assert_match(/\Aerror:.*File ext is invalid/, upload.status)
        end
      end
    end

    context "#finish!" do
      setup do
        CurrentUser.user = travel_to(1.month.ago) do
          FactoryBot.create(:user)
        end
        CurrentUser.ip_addr = "127.0.0.1"
        @source = "https://twitter.com/nounproject/status/540944400767922176"
      end

      should "overwrite the attributes" do
        @service = UploadService::Preprocessor.new(source: @source, rating: 'e')
        @upload = @service.start!
        @service.finish!
        @upload.reload
        assert_equal('e', @upload.rating)
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
        as(@user) do
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
            as(@user) { subject.process! }
          end
        end

        should "create a comment" do
          assert_difference(-> { @post.comments.count }) do
            as(@user) { subject.process! }
            @post.reload
          end
        end

        should "not create a new post" do
          assert_difference(-> { Post.count }, 0) do
            as(@user) { subject.process! }
          end
        end

        should "update the post's MD5" do
          assert_changes(-> { @post.md5 }) do
            as(@user) { subject.process! }
            @post.reload
          end
        end

        should "preserve the old values" do
          as(@user) { subject.process! }
          assert_equal(1500, @replacement.image_width_was)
          assert_equal(1000, @replacement.image_height_was)
          assert_equal(2000, @replacement.file_size_was)
          assert_equal("jpg", @replacement.file_ext_was)
          assert_equal(@old_md5, @replacement.md5_was)
        end

        should "record the new values" do
          as(@user) { subject.process! }
          assert_equal(500, @replacement.image_width)
          assert_equal(335, @replacement.image_height)
          assert_equal(28086, @replacement.file_size)
          assert_equal("jpg", @replacement.file_ext)
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @replacement.md5)
        end

        should "correctly update the attributes" do
          as(@user) { subject.process! }
          assert_equal(500, @post.image_width)
          assert_equal(335, @post.image_height)
          assert_equal(28086, @post.file_size)
          assert_equal("jpg", @post.file_ext)
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @post.md5)
          assert(File.exist?(@post.file.path))
        end
      end

      context "a post with the same file" do
        should "not raise a duplicate error" do
          upload_file("test/files/test.png") do |file|
            assert_nothing_raised do
              as(@user) { @post.replace!(replacement_file: file, replacement_url: "") }
            end
          end
        end

        should "not queue a deletion or log a comment" do
          upload_file("test/files/test.png") do |file|
            assert_no_difference(-> { @post.comments.count }) do
              as(@user) { @post.replace!(replacement_file: file, replacement_url: "") }
              @post.reload
            end
          end
        end
      end
    end

    context "for a twitter source replacement" do
      setup do
        @new_url = "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig"

        travel_to(1.month.ago) do
          @user = FactoryBot.create(:user)
        end

        as(@user) do
          @post = FactoryBot.create(:post, source: "http://blah", file_ext: "jpg", md5: "something", uploader_ip_addr: "127.0.0.2")
          @post.stubs(:queue_delete_files)
          @replacement = FactoryBot.create(:post_replacement, post: @post, replacement_url: @new_url)
        end
      end

      subject { UploadService::Replacer.new(post: @post, replacement: @replacement) }

      should "replace the post" do
        as(@user) { subject.process! }

        @post.reload

        assert_equal(@new_url, @post.replacements.last.replacement_url)
      end
    end

    context "for a source replacement" do
      setup do
        @new_url = "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"
        @new_md5 = "d34e4cf0a437a5d65f8e82b7bcd02606"
        travel_to(1.month.ago) do
          @user = FactoryBot.create(:user)
        end
        as(@user) do
          @post_md5 = "710fd9cba4ef37260f9152ffa9d154d8"
          @post = FactoryBot.create(:post, source: "https://cdn.donmai.us/original/71/0f/#{@post_md5}.png", file_ext: "png", md5: @post_md5, uploader_ip_addr: "127.0.0.2")
          @post.stubs(:queue_delete_files)
          @replacement = FactoryBot.create(:post_replacement, post: @post, replacement_url: @new_url)
        end
      end

      subject { UploadService::Replacer.new(post: @post, replacement: @replacement) }

      context "when replacing with its own source" do
        should "work" do
          as(@user) { @post.replace!(replacement_url: @post.source) }
          assert_equal(@post_md5, @post.md5)
          assert_match(/#{@post_md5}/, @post.file_path)
        end
      end

      context "when an upload with the same MD5 already exists" do
        setup do
          @post.update(md5: @new_md5)
          as(@user) do
            @post2 = FactoryBot.create(:post)
            @post2.stubs(:queue_delete_files)
          end
        end

        should "throw an error" do
          assert_raises(UploadService::Replacer::Error) do
            as(@user) { @post2.replace!(replacement_url: @new_url) }
          end
        end
      end

      context "a post when given a final_source" do
        should "change the source to the final_source" do
          replacement_url = "https://cdn.donmai.us/original/fd/b4/fdb47f79fb8da82e66eeb1d84a1cae8d.jpg"
          final_source = "https://cdn.donmai.us/original/71/0f/710fd9cba4ef37260f9152ffa9d154d8.png"

          as(@user) { @post.replace!(replacement_url: replacement_url, final_source: final_source) }

          assert_equal(final_source, @post.source)
        end
      end

      context "a post when replaced with a HTML source" do
        should "record the image URL as the replacement URL, not the HTML source" do
          skip "Twitter key not set" unless Danbooru.config.twitter_api_key
          replacement_url = "https://twitter.com/nounproject/status/540944400767922176"
          image_url = "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig"
          as(@user) { @post.replace!(replacement_url: replacement_url) }

          assert_equal(replacement_url, @post.replacements.last.replacement_url)
        end
      end

      context "#undo!" do
        setup do
          @user = travel_to(1.month.ago) { FactoryBot.create(:user) }
          as(@user) do
            @post = FactoryBot.create(:post, source: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg")
            @post.stubs(:queue_delete_files)
            @post.replace!(replacement_url: "https://cdn.donmai.us/original/fd/b4/fdb47f79fb8da82e66eeb1d84a1cae8d.jpg", tags: "-tag1 tag2")
          end

          @replacement = @post.replacements.last
        end

        should "update the attributes" do
          as(@user) do
            subject.undo!
          end

          assert_equal("tag2", @post.tag_string)
          assert_equal(459, @post.image_width)
          assert_equal(650, @post.image_height)
          assert_equal(127238, @post.file_size)
          assert_equal("jpg", @post.file_ext)
          assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", @post.md5)
          assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", Digest::MD5.file(@post.file).hexdigest)
          assert_equal("https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg", @post.source)
        end
      end

      context "#process!" do
        should "create a new upload" do
          assert_difference(-> { Upload.count }) do
            as(@user) { subject.process! }
          end
        end

        should "create a comment" do
          assert_difference(-> { @post.comments.count }) do
            as(@user) { subject.process! }
            @post.reload
          end
        end

        should "not create a new post" do
          assert_difference(-> { Post.count }, 0) do
            as(@user) { subject.process! }
          end
        end

        should "update the post's MD5" do
          assert_changes(-> { @post.md5 }) do
            as(@user) { subject.process! }
            @post.reload
          end
        end

        should "update the post's source" do
          assert_changes(-> { @post.source }, nil, from: @post.source, to: @new_url) do
            as(@user) { subject.process! }
            @post.reload
          end
        end

        should "not change the post status or uploader" do
          assert_no_changes(-> { {ip_addr: @post.uploader_ip_addr.to_s, uploader: @post.uploader_id, pending: @post.is_pending?} }) do
            as(@user) { subject.process! }
            @post.reload
          end
        end

        should "leave a system comment" do
          as(@user) { subject.process! }
          comment = @post.comments.last
          assert_not_nil(comment)
          assert_equal(User.system.id, comment.creator_id)
          assert_match(/replaced this post/, comment.body)
        end
      end

      context "a post with a pixiv html source" do
        should "replace with the full size image" do
          as(@user) do
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
        end

        should "delete the old files after thirty days" do
          @post.unstub(:queue_delete_files)
          FileUtils.expects(:rm_f).times(3)

          as(@user) { @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350") }

          travel_to((PostReplacement::DELETION_GRACE_PERIOD + 1).days.from_now) do
            perform_enqueued_jobs
          end
        end
      end

      context "a post that is replaced by a ugoira" do
        should "save the frame data" do
          skip unless MediaFile::Ugoira.videos_enabled?
          begin
            as(@user) { @post.replace!(replacement_url: "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364") }
            @post.reload

            assert_equal(80, @post.image_width)
            assert_equal(82, @post.image_height)
            assert_equal(2804, @post.file_size)
            assert_equal("zip", @post.file_ext)
            assert_equal("cad1da177ef309bf40a117c17b8eecf5", @post.md5)
            assert_equal("cad1da177ef309bf40a117c17b8eecf5", Digest::MD5.file(@post.file).hexdigest)

            assert_equal("https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip", @post.source)
            assert_equal([{"delay" => 125, "file" => "000000.jpg"}, {"delay" => 125, "file" => "000001.jpg"}], @post.pixiv_ugoira_frame_data.data)
          end
        end
      end

      context "a post that is replaced to another file then replaced back to the original file" do
        should "not delete the original files" do
          skip unless MediaFile::Ugoira.videos_enabled?
          @post.unstub(:queue_delete_files)

          # this is called thrice to delete the file for 62247364
          FileUtils.expects(:rm_f).times(3)

          as(@user) do
            @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
            @post.reload
            @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
            @post.reload
            Upload.destroy_all
            @post.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
          end

          assert_nothing_raised { @post.file(:original) }
          assert_nothing_raised { @post.file(:preview) }

          assert_enqueued_jobs 3, only: DeletePostFilesJob
          travel PostReplacement::DELETION_GRACE_PERIOD + 1.day
          assert_raise(Post::DeletionError) { perform_enqueued_jobs }

          assert_nothing_raised { @post.file(:original) }
          assert_nothing_raised { @post.file(:preview) }
        end
      end

      context "two posts that have had their files swapped" do
        setup do
          as(@user) do
            @post1 = FactoryBot.create(:post)
            @post2 = FactoryBot.create(:post)
          end
        end

        should "not delete the still active files" do
          # swap the images between @post1 and @post2.
          as(@user) do
            skip unless MediaFile::Ugoira.videos_enabled?

            @post1.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
            @post2.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
            assert_equal("4ceadc314938bc27f3574053a3e1459a", @post1.md5)
            assert_equal("cad1da177ef309bf40a117c17b8eecf5", @post2.md5)

            @post2.reload
            @post2.replace!(replacement_url: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg")
            assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", @post2.md5)
            Upload.destroy_all
            @post1.reload
            @post2.reload

            @post1.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
            @post2.replace!(replacement_url: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350")
            assert_equal("cad1da177ef309bf40a117c17b8eecf5", @post1.md5)
            assert_equal("4ceadc314938bc27f3574053a3e1459a", @post2.md5)
          end

          travel_to (PostReplacement::DELETION_GRACE_PERIOD + 1).days.from_now do
            assert_raise(Post::DeletionError) do
              perform_enqueued_jobs
            end
          end

          assert_nothing_raised { @post1.file(:original) }
          assert_nothing_raised { @post2.file(:original) }
        end
      end

      context "a post with notes" do
        setup do
          Note.any_instance.stubs(:merge_version?).returns(false)

          as(@user) do
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
              as(@user) do
                @post.replace!(
                  replacement_url: "https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png",
                  final_source: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350"
                )
              end
              @note.reload
            end

            assert_equal([40, 41, 40, 41], [@note.x, @note.y, @note.width, @note.height])
            assert_equal("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350", @post.source)
          end
        end
      end
    end
  end

  context "#start!" do
    subject { UploadService }

    setup do
      @source = "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"
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
        Danbooru.config.stubs(:max_image_resolution).returns(31 * 31)
      end

      should "should fail validation" do
        service = subject.new(file: upload_file("test/files/test-large.jpg"))
        upload = service.start!
        assert_match(/image resolution is too large/, upload.status)
      end
    end

    context "with a preprocessing predecessor" do
      setup do
        @predecessor = FactoryBot.create(:source_upload, status: "preprocessing", source: @source, image_height: 0, image_width: 0, file_ext: "jpg")
      end

      should "schedule a job later" do
        service = subject.new(source: @source)

        predecessor = service.start!
        assert_enqueued_jobs(1, only: UploadServiceDelayedStartJob)
        assert_equal(@predecessor, predecessor)
      end
    end

    context "with a preprocessed predecessor" do
      setup do
        @predecessor = FactoryBot.create(:source_upload, status: "preprocessed", source: @source, image_height: 0, image_width: 0, file_size: 1, md5: 'd34e4cf0a437a5d65f8e82b7bcd02606', file_ext: "jpg")
        @tags = 'hello world'
      end

      should "update the predecessor" do
        service = subject.new(source: @source, tag_string: @tags)

        predecessor = service.start!
        assert_equal(@predecessor, predecessor)
        assert_equal(@tags, predecessor.tag_string.strip)
      end

      context "when the file has already been uploaded" do
        setup do
          @post = create(:post, md5: "d34e4cf0a437a5d65f8e82b7bcd02606")
          @service = subject.new(source: @source)
        end

        should "point to the dup post in the upload" do
          @upload = subject.new(source: @source, tag_string: @tags).start!
          @predecessor.reload
          assert_equal("error: ActiveRecord::RecordInvalid - Validation failed: Md5 duplicate: #{@post.id}", @predecessor.status)
        end
      end
    end

    context "with no predecessor" do
      should "create an upload" do
        service = subject.new(source: @source)

        assert_difference(-> { Upload.count }) do
          service.start!
        end
      end

      should "assign the rating from tags" do
        service = subject.new(source: @source, tag_string: "rating:safe blah")
        upload = service.start!

        assert_equal(true, upload.valid?)
        assert_equal("s", upload.rating)
        assert_equal("rating:safe blah ", upload.tag_string)

        assert_equal("s", upload.post.rating)
        assert_equal("blah", upload.post.tag_string)
      end
    end

    context "with a source containing unicode characters" do
      should "upload successfully" do
        source1 = "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg?one=東方&two=a%20b"
        source2 = "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg?one=%E6%9D%B1%E6%96%B9&two=a%20b"
        service = subject.new(source: source1, rating: "s")

        assert_nothing_raised { @upload = service.start! }
        assert_equal(true, @upload.is_completed?)
        assert_equal(source2, @upload.source)
      end

      should "normalize unicode characters in the source field" do
        source1 = "poke\u0301mon" # pokémon (nfd form)
        source2 = "pok\u00e9mon"  # pokémon (nfc form)
        service = subject.new(source: source1, rating: "s", file: upload_file("test/files/test.jpg"))

        assert_nothing_raised { @upload = service.start! }
        assert_equal(source2, @upload.source)
      end
    end

    context "without a file or a source url" do
      should "fail gracefully" do
        service = subject.new(source: "blah", rating: "s")

        assert_nothing_raised { @upload = service.start! }
        assert_equal(true, @upload.is_errored?)
        assert_match(/No file or source URL provided/, @upload.status)
      end
    end

    context "with both a file and a source url" do
      should "upload the file and set the source field to the given source" do
        service = subject.new(file: upload_file("test/files/test.jpg"), source: "http://www.example.com", rating: "s")

        assert_nothing_raised { @upload = service.start! }
        assert_equal(true, @upload.is_completed?)
        assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @upload.md5)
        assert_equal("http://www.example.com", @upload.source)
      end
    end

    context "for a corrupted image" do
      should "fail for a corrupted jpeg" do
        @bad_jpeg_path = "test/files/test-corrupt.jpg"

        upload = upload_from_file(@bad_jpeg_path)
        assert_match(/corrupt/, upload.status)
      end

      should "fail for a corrupted gif" do
        @bad_gif_path = "test/files/test-corrupt.gif"

        upload = upload_from_file(@bad_gif_path)
        assert_match(/corrupt/, upload.status)
      end

      # https://schaik.com/pngsuite/pngsuite_xxx_png.html
      should "fail for a corrupted png" do
        @bad_png_path = "test/files/test-corrupt.png"

        upload = upload_from_file(@bad_png_path)
        assert_match(/corrupt/, upload.status)
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

    context "for a pixiv" do
      setup do
        @source = "https://i.pximg.net/img-original/img/2017/11/21/05/12/37/65981735_p0.jpg"
        @ref = "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65981735"
        @upload = FactoryBot.create(:jpg_upload, file_size: 1000, md5: "12345", file_ext: "jpg", image_width: 100, image_height: 100, source: @source, referer_url: @ref)
      end

      should "record the canonical source" do
        post = subject.new({}).create_post_from_upload(@upload)
        assert_equal(@source, post.source)
      end
    end

    context "for a twitter" do
      setup do
        @source = "https://pbs.twimg.com/media/C1kt72yVEAEGpOv.jpg:large"
        @ref = "https://twitter.com/aranobu/status/817736083567820800"
        @upload = FactoryBot.create(:jpg_upload, file_size: 1000, md5: "12345", file_ext: "jpg", image_width: 100, image_height: 100, source: @source, referer_url: @ref)
      end

      should "record the canonical source" do
        post = subject.new({}).create_post_from_upload(@upload)
        assert_equal(@ref, post.source)
      end
    end

    context "for a pixiv ugoira" do
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

    context "for nijie" do
      should "record the canonical source" do
        page_url = "https://nijie.info/view.php?id=728995"
        image_url = "https://pic03.nijie.info/nijie_picture/728995_20170505014820_0.jpg"
        upload = FactoryBot.create(:jpg_upload, file_size: 1000, md5: "12345", file_ext: "jpg", image_width: 100, image_height: 100, source: image_url, referer_url: page_url)

        post = UploadService.new({}).create_post_from_upload(upload)
        assert_equal(page_url, post.source)
      end
    end

    context "for an image" do
      setup do
        @upload = FactoryBot.create(:source_upload, file_size: 1000, md5: "12345", file_ext: "jpg", image_width: 100, image_height: 100)
      end

      should "create a commentary record if the commentary is present" do
        assert_difference("ArtistCommentary.count", 1) do
          @upload.update!(
            artist_commentary_title: "blah",
            artist_commentary_desc: "blah",
            translated_commentary_title: "blah",
            translated_commentary_desc: "blah"
          )
          UploadService.new({}).create_post_from_upload(@upload)
        end
      end

      should "not create a commentary record if the commentary is blank" do
        assert_difference("ArtistCommentary.count", 0) do
          @upload.update!(
            artist_commentary_title: "",
            artist_commentary_desc: "",
            translated_commentary_title: "",
            translated_commentary_desc: ""
          )
          UploadService.new({}).create_post_from_upload(@upload)
        end
      end

      should "create a post" do
        post = subject.new({}).create_post_from_upload(@upload)
        assert_equal([], post.errors.full_messages)
        assert_not_nil(post.id)
      end
    end
  end

  context "Upload#prune!" do
    setup do
      @user = create(:user, created_at: 1.year.ago)
    end

    should "delete stale upload records" do
      @upload = as(@user) { UploadService.new(file: upload_file("test/files/test.jpg")).start! }
      @upload.update!(created_at: 1.month.ago)

      assert_difference("Upload.count", -1) { Upload.prune! }
    end

    should "delete unused files after deleting the upload" do
      @upload = as(@user) { UploadService::Preprocessor.new(file: upload_file("test/files/test.jpg")).start! }
      assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :original)))

      @upload.destroy!
      refute(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :original)))
    end

    should "not delete files that are still in use by a post" do
      @upload = as(@user) { UploadService.new(file: upload_file("test/files/test.jpg")).start! }
      assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :original)))

      @upload.destroy!
      assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :original)))
    end

    should "not delete files if they're still in use by another upload" do
      @upload1 = as(@user) { UploadService::Preprocessor.new(file: upload_file("test/files/test.jpg")).start! }
      @upload2 = as(@user) { UploadService::Preprocessor.new(file: upload_file("test/files/test.jpg")).start! }
      assert_equal(@upload1.md5, @upload2.md5)
      assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload1.md5, "jpg", :original)))

      @upload1.destroy!
      assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload1.md5, "jpg", :original)))

      @upload2.destroy!
      refute(File.exist?(Danbooru.config.storage_manager.file_path(@upload2.md5, "jpg", :original)))
    end

    should "not delete files that were replaced after upload and are still pending deletion" do
      @upload = as(@user) { UploadService.new(file: upload_file("test/files/test.jpg")).start! }
      assert(@upload.is_completed?)

      as(@user) { @upload.post.replace!(replacement_file: upload_file("test/files/test.png"), replacement_url: "") }
      assert_not_equal(@upload.md5, @upload.post.md5)

      # after replacement the uploaded file is no longer in use, but it shouldn't be
      # deleted yet. it should only be deleted by the replacer after the grace period.
      @upload.destroy!
      assert(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :original)))

      travel (PostReplacement::DELETION_GRACE_PERIOD + 1).days
      perform_enqueued_jobs
      refute(File.exist?(Danbooru.config.storage_manager.file_path(@upload.md5, "jpg", :original)))
    end

    should "work on uploads without a file" do
      @upload = as(@user) { UploadService.new(source: "http://14903gf0vm3g134yjq3n535yn3n.com/does_not_exist.jpg").start! }

      assert(@upload.is_errored?)
      assert_difference("Upload.count", -1) { @upload.destroy! }
    end
  end
end
