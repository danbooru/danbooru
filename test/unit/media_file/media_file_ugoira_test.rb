require "test_helper"
require "zip"

class MediaFileUgoiraTest < ActiveSupport::TestCase
  context "#dimensions" do
    should "determine the correct dimensions for a ugoira file" do
      skip unless MediaFile.videos_enabled?
      frame_delays = JSON.parse(File.read("test/files/ugoira/animation.json")).pluck("delay")
      assert_equal([60, 60], MediaFile.open("test/files/ugoira/ugoira.zip", frame_delays: frame_delays).dimensions)
    end
  end

  context "#file_ext" do
    should "determine the correct extension for a ugoira file" do
      assert_equal(:zip, MediaFile.open("test/files/ugoira/ugoira.zip").file_ext)
    end
  end

  context "A ugoira:" do
    context "a .zip file without an animation.json file or separate frame delays" do
      should "not be recognized as a ugoira" do
        file = MediaFile.open("test/files/ugoira/ugoira.zip")

        assert_equal(MediaFile, file.class)
        assert_equal(:zip, file.file_ext)
        assert_equal("application/zip", file.mime_type.to_s)
      end
    end

    context "a ugoira .zip file without an animation.json file but with separate frame delays" do
      setup do
        frame_delays = JSON.parse(File.read("test/files/ugoira/animation.json")).pluck("delay")
        @ugoira = MediaFile.open("test/files/ugoira/ugoira.zip", frame_delays: frame_delays)
      end

      should "generate a preview" do
        assert_equal([60, 60], @ugoira.preview(150, 150).dimensions)
      end

      should "get the metadata" do
        assert_equal(:zip, @ugoira.file_ext)
        assert_equal("video/x-ugoira", @ugoira.mime_type.to_s)
        assert_equal(1.05, @ugoira.duration)
        assert_equal(4.76, @ugoira.frame_rate.round(2))
        assert_equal(5, @ugoira.files.size)
        assert_equal(5, @ugoira.frame_count)
        assert_equal("af38ac9842a0afe344a66d377d91c842", @ugoira.pixel_hash)
        assert_equal("0d94800c4b520bf3d8adda08f95d31e2", @ugoira.md5)

        assert_equal([200, 200, 200, 200, 250], @ugoira.metadata["Ugoira:FrameDelays"])
        assert_equal([0, 1679, 3588, 5189, 5989], @ugoira.metadata["Ugoira:FrameOffsets"])
        assert_equal(5, @ugoira.metadata["Ugoira:FrameCount"])
        assert_equal(4.76, @ugoira.metadata["Ugoira:FrameRate"].round(2))
        assert_equal("image/jpeg", @ugoira.metadata["Ugoira:FrameMimeType"])
        assert_equal("none", @ugoira.metadata["Ugoira:AnimationJsonFormat"])

        assert_nil(@ugoira.animation_json)
        assert_nil(@ugoira.error)
      end

      should "convert to a webm" do
        skip unless MediaFile::Ugoira.videos_enabled?

        webm = @ugoira.convert
        assert_equal(:webm, webm.file_ext)
        assert_equal([60, 60], webm.dimensions)
      end

      should "clean up the extracted files" do
        paths = @ugoira.files.map(&:path)
        tmpdir = @ugoira.tmpdir.path

        assert(paths.all? { |path| File.exist?(path) })
        assert(File.exist?(tmpdir))

        @ugoira.close

        assert(paths.none? { |path| File.exist?(path) })
        assert_not(File.exist?(tmpdir))
      end

      should "be able to create a new ugoira with an animation.json file" do
        new_ugoira = MediaFile::Ugoira.create(@ugoira.frames, frame_delays: @ugoira.frame_delays)

        assert_equal(6, new_ugoira.files.size)
        assert_equal(5, new_ugoira.frame_count)
        assert_equal(60, new_ugoira.animation_json[:width])
        assert_equal(60, new_ugoira.animation_json[:height])
        assert_equal(7_202, new_ugoira.size)
        assert_equal("af38ac9842a0afe344a66d377d91c842", new_ugoira.pixel_hash)
        assert_equal("e0bd8afa96e30605e4bc4a3f9585afd6", new_ugoira.md5)

        assert_equal(60, new_ugoira.animation_json[:width])
        assert_equal(60, new_ugoira.animation_json[:height])
        assert_equal("image/jpeg", new_ugoira.animation_json[:mime_type])
        assert_equal([200, 200, 200, 200, 250], new_ugoira.animation_json[:frames].pluck("delay"))
        assert_equal(%w[000000.jpg 000001.jpg 000002.jpg 000003.jpg 000004.jpg], new_ugoira.animation_json[:frames].pluck("file"))
        assert_equal(@ugoira.frames.map(&:md5), new_ugoira.animation_json[:frames].pluck("md5"))
        assert_equal([0, 1679, 3588, 5189, 5989], new_ugoira.metadata["Ugoira:FrameOffsets"])
        assert_equal("image/jpeg", new_ugoira.metadata["Ugoira:FrameMimeType"])
        assert_equal("Danbooru", new_ugoira.metadata["Ugoira:AnimationJsonFormat"])

        assert_nil(new_ugoira.error)
      end
    end

    context "A ugoira .zip file with an animation.json in gallery-dl format" do
      should "find the files and frame delays" do
        MediaFile.open("test/files/ugoira/ugoira-95239241-gallery-dl.zip") do |ugoira|
          assert_equal(79_276, ugoira.size)
          assert_equal("68007e305a081faae3be65d3edbd4eb1", ugoira.pixel_hash)
          assert_equal("7fe767b4e202415a2b2dec2a82be3b69", ugoira.md5)
          assert_equal(11, ugoira.files.size)
          assert_equal(10, ugoira.frame_count)
          assert_equal(10, ugoira.animation_json.size)
          assert_equal("gallery-dl", ugoira.animation_json_format)
          assert_equal([0, 7817, 15_616, 23_444, 31_274, 39_087, 46_931, 54_807, 62_599, 70_394], ugoira.frame_offsets)
          assert_equal(1.7, ugoira.duration)
          assert_nil(ugoira.error)
        end
      end
    end

    context "A ugoira .zip file with an animation.json in PixivUtil2 format" do
      should "find the files and frame delays" do
        MediaFile.open("test/files/ugoira/ugoira-95239241-pixivutil2.zip") do |ugoira|
          assert_equal(41_745, ugoira.size)
          assert_equal("68007e305a081faae3be65d3edbd4eb1", ugoira.pixel_hash)
          assert_equal("dbfe1d5764eb24f3d55224f85ef3383c", ugoira.md5)
          assert_equal(11, ugoira.files.size)
          assert_equal(10, ugoira.frame_count)
          assert_equal(10, ugoira.animation_json[:frames].size)
          assert_equal("PixivUtil2", ugoira.animation_json_format)
          assert_equal([0, 4046, 8074, 12_123, 16_169, 20_204, 24_262, 28_337, 32_372, 36_405], ugoira.frame_offsets)
          assert_equal(1.7, ugoira.duration)
          assert_nil(ugoira.error)
        end
      end
    end

    context "A ugoira .zip file with an animation.json in PixivToolkit format" do
      should "find the files and frame delays" do
        MediaFile.open("test/files/ugoira/ugoira-95239241-pixivtoolkit.zip") do |ugoira|
          assert_equal(41_747, ugoira.size)
          assert_equal("68007e305a081faae3be65d3edbd4eb1", ugoira.pixel_hash)
          assert_equal("8d03702cc61e625b03cca3d556a163a1", ugoira.md5)
          assert_equal(11, ugoira.files.size)
          assert_equal(10, ugoira.frame_count)
          assert_equal(10, ugoira.animation_json.dig(:ugokuIllustData, :frames).size)
          assert_equal("PixivToolkit", ugoira.animation_json_format)
          assert_equal([639, 4685, 8713, 12_762, 16_808, 20_843, 24_901, 28_976, 33_011, 37_044], ugoira.frame_offsets)
          assert_equal(1.7, ugoira.duration)
          assert_nil(ugoira.error)
        end
      end
    end

    context "A ugoira .zip file with an animation.json in Danbooru format" do
      should "find the files and frame delays" do
        MediaFile.open("test/files/ugoira/ugoira-95239241-danbooru.zip") do |ugoira|
          assert_equal(79_865, ugoira.size)
          assert_equal("68007e305a081faae3be65d3edbd4eb1", ugoira.pixel_hash)
          assert_equal("72e8c2f6c6783efaeb4830d26ddfd17d", ugoira.md5)
          assert_equal(11, ugoira.files.size)
          assert_equal(10, ugoira.frame_count)
          assert_equal(10, ugoira.animation_json[:frames].size)
          assert_equal("Danbooru", ugoira.animation_json_format)
          assert_equal([0, 7817, 15_616, 23_444, 31_274, 39_087, 46_931, 54_807, 62_599, 70_394], ugoira.frame_offsets)
          assert_equal(1.7, ugoira.duration)
          assert_nil(ugoira.error)
        end
      end
    end

    context "An unpacked ugoira without an animation.json file" do
      should "find the files and frame delays" do
        Danbooru::Archive.extract!("test/files/ugoira/ugoira.zip") do |tmpdir|
          frame_delays = File.read("test/files/ugoira/animation.json").parse_json.pluck("delay")
          files = Pathname.new(tmpdir).glob("*")
          ugoira = MediaFile::Ugoira.new(files, frame_delays: frame_delays)

          assert_equal(5, ugoira.files.size)
          assert_equal(5, ugoira.frame_count)
          assert_equal(1.05, ugoira.duration)
          assert_equal("none", ugoira.animation_json_format)

          ugoira.close
        end
      end
    end

    context "An unpacked ugoira with an animation.json file in gallery-dl format" do
      should "find the files and frame delays" do
        Danbooru::Archive.extract!("test/files/ugoira/ugoira-95239241-gallery-dl.zip") do |tmpdir|
          files = Pathname.new(tmpdir).glob("*")
          ugoira = MediaFile::Ugoira.new(files)

          assert_equal(11, ugoira.files.size)
          assert_equal(10, ugoira.frame_count)
          assert_equal(1.7, ugoira.duration)
          assert_equal("gallery-dl", ugoira.animation_json_format)

          ugoira.close
        end
      end
    end

    context "that is a ZIP64 file" do
      should "be rejected" do
        Danbooru::Tempfile.create(["danbooru-ugoira-zip64-", ".zip"]) do |file|
          Zip::File.open(file.path, create: true, compression_level: 0) do |zip|
            %w[000000.jpg 000001.jpg].each do |name|
              entry = Zip::Entry.new(zip, name)
              entry.extra.create(:zip64)
              zip.add(entry, "test/files/test.jpg")
            end
          end

          MediaFile::Ugoira.open(file.path, frame_delays: [100, 100]) do |ugoira|
            assert_equal("zip64 format is not supported", ugoira.error)
          end
        end
      end
    end

    context "Conversion of a ugoira" do
      should "not fail when converting two ugoiras concurrently" do
        a = Thread.new { MediaFile.open("test/files/ugoira/ugoira-95239241-danbooru.zip").convert }
        b = Thread.new { MediaFile.open("test/files/ugoira/ugoira-100260240-png-danbooru.zip").convert }

        assert_nothing_raised { [a, b].each(&:value) }
      end

      context "with odd dimensions" do
        setup do
          @frame_delays = JSON.parse(File.read("test/files/ugoira/animation.json")).pluck("delay")
          @ugoira = MediaFile.open("test/files/ugoira/ugoira.zip", frame_delays: @frame_delays)
        end

        should "pad the dimensions for h264, h265, and av1" do
          assert_equal([64, 64], @ugoira.convert(width: 63, height: 63, format: :mp4, codec: :h264).dimensions)
          assert_equal([64, 64], @ugoira.convert(width: 63, height: 63, format: :mp4, codec: :h265).dimensions)
          assert_equal([64, 64], @ugoira.convert(width: 63, height: 63, format: :webm, codec: :av1).dimensions)
        end

        should "not pad the dimensions for vp8 or vp9" do
          assert_equal([63, 63], @ugoira.convert(width: 63, height: 63, format: :webm, codec: :vp8).dimensions)
          assert_equal([63, 63], @ugoira.convert(width: 63, height: 63, format: :webm, codec: :vp9).dimensions)
        end
      end

      formats = { mp4: %i[h264 hevc vp9 av1], webm: %i[vp8 vp9] }

      formats.each do |format, codecs|
        codecs.each do |codec|
          context "with JPEG frames" do
            should "work when converting to a #{codec} #{format}" do
              MediaFile.open("test/files/ugoira/ugoira-95239241-danbooru.zip") do |ugoira|
                video = ugoira.convert(format: format, codec: codec)

                assert_equal(format, video.file_ext)
                assert_equal(codec, video.video_codec.to_sym)
                assert_equal([384, 384], ugoira.dimensions)
                assert_equal([384, 384], video.dimensions)
                assert_equal(10, ugoira.frame_count)
                assert_equal(10, video.frame_count)
                assert_equal([170] * 10, ugoira.frame_delays)
                assert_equal([170] * 10, video.frame_durations)
                assert_equal(1.7, ugoira.duration)
                assert_equal(1.7, video.duration)
                assert_equal(1.7, video.playback_duration)
                assert_equal(codec.in?(%i[h264 hevc]) ? "yuvj420p" : "yuv420p", video.pix_fmt)
                assert_equal(true, video.is_supported?)
              end
            end
          end

          context "with PNG frames" do
            should "work when converting to a #{codec} #{format}" do
              MediaFile.open("test/files/ugoira/ugoira-100260240-png-danbooru.zip") do |ugoira|
                video = ugoira.convert(format: format, codec: codec)

                assert_equal(format, video.file_ext)
                assert_equal(codec, video.video_codec.to_sym)
                assert_equal([370, 370], ugoira.dimensions)
                assert_equal([370, 370], video.dimensions)
                assert_equal(8, ugoira.frame_count)
                assert_equal(8, video.frame_count)
                assert_equal(1.0, ugoira.duration)
                assert_equal(1.0, video.duration)
                assert_equal([125] * 8, ugoira.frame_delays)
                assert_equal([125] * 8, video.frame_durations)
                assert_equal("yuv420p", video.pix_fmt)
                assert_equal(true, video.is_supported?)
              end
            end
          end

          context "with GIF frames" do
            should "work when converting to a #{codec} #{format}" do
              MediaFile.open("test/files/ugoira/ugoira-108469527-gif-danbooru.zip") do |ugoira|
                video = ugoira.convert(format: format, codec: codec)

                assert_equal(format, video.file_ext)
                assert_equal(codec, video.video_codec.to_sym)
                assert_equal([300, 300], ugoira.dimensions)
                assert_equal([300, 300], video.dimensions)
                assert_equal(30, ugoira.frame_count)
                assert_equal(30, video.frame_count)
                assert_equal([70] * 30, ugoira.frame_delays)
                assert_equal([70] * 30, video.frame_durations)
                assert_equal(2.1, ugoira.duration)
                assert_equal(2.1, video.duration)
                assert_equal("yuv420p", video.pix_fmt)
                assert_equal(true, video.is_supported?)
              end
            end
          end
        end

        should "generate the correct frame durations for a variable frame rate ugoira converted to #{format}" do
          ugoira = MediaFile.open("test/files/ugoira/ugoira.zip", frame_delays: [1000, 2000, 3000, 4000, 5000])
          video = ugoira.convert(format: format)

          assert_equal([1000, 2000, 3000, 4000, 5000], video.frame_durations)
          assert_equal(15.0, video.duration)
          assert_equal(15.0, video.playback_duration)
        end
      end
    end
  end
end
