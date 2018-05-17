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
        subject.expects(:distribute_files).twice
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

    context "#download_from_source" do
      setup do
        @jpeg = "https://upload.wikimedia.org/wikipedia/commons/c/c5/Moraine_Lake_17092005.jpg"
        @ugoira = "https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip"
      end

      should "work on a jpeg" do
        file = subject.new({}).download_from_source(@jpeg) do |context|
          assert_not_nil(context[:downloaded_source])
          assert_not_nil(context[:source])
        end

        assert_operator(File.size(file.path), :>, 0)
        file.close
      end

      should "work on an ugoira url" do
        file = subject.new({}).download_from_source(@ugoira, referer_url: "https://www.pixiv.net") do |context|
          assert_not_nil(context[:downloaded_source])
          assert_not_nil(context[:source])
          assert_not_nil(context[:ugoira])
        end

        assert_operator(File.size(file.path), :>, 0)
        file.close
      end
    end

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
        @upload = @service.start!
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
        @upload = @service.start!
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
        @upload = @service.start!
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
          @upload = @service.start!
          assert_match(/error:/, @upload.status)
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
        @predecessor = FactoryBot.create(:source_upload, status: "preprocessed", source: @source, image_height: 0, image_width: 0, file_ext: "jpg")
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
