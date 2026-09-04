require "test_helper"
require "zip"

class MediaFileUgoiraTest < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "ugoira",
        "test/files/ugoira/invalid_ugoira.zip" => nil,
        "test/files/ugoira/ugoira-100260240-png-danbooru.zip" => [150, 150, "36433ece2c131751e20bf3be809a6e1a"],
        "test/files/ugoira/ugoira-108469527-gif-danbooru.zip" => [150, 150, "6df09b3f91c47146f5c9e633517b67bd"],
        "test/files/ugoira/ugoira-95239241-danbooru.zip" => [150, 150, "00c0a1bf3fcfa29053b64ac33d2e6920"],
        "test/files/ugoira/ugoira-95239241-gallery-dl.zip" => [150, 150, "00c0a1bf3fcfa29053b64ac33d2e6920"],
        "test/files/ugoira/ugoira-95239241-pixiv.zip" => nil,
        "test/files/ugoira/ugoira-95239241-pixivtoolkit.zip" => [150, 150, "00c0a1bf3fcfa29053b64ac33d2e6920"],
        "test/files/ugoira/ugoira-95239241-pixivutil2.zip" => [150, 150, "00c0a1bf3fcfa29053b64ac33d2e6920"],
        "test/files/ugoira/ugoira.zip" => nil,
      )
    end
  end

  context "a ugoira zip file" do
    should "be parsed correctly" do
      frame_delays = File.read("test/files/ugoira/animation.json").parse_json.pluck("delay")
      file = MediaFile.open("test/files/ugoira/ugoira.zip", frame_delays: frame_delays)

      assert_equal(60, file.width)
      assert_equal(60, file.height)
      assert_equal(6663, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("video/x-ugoira", file.mime_type)
      assert_equal("0d94800c4b520bf3d8adda08f95d31e2", file.md5)
      assert_equal("af38ac9842a0afe344a66d377d91c842", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.05, file.duration)
      assert_equal(5, file.frame_count)
      assert_equal(4.761904761904762, file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "Ugoira:FrameDelays" => [200, 200, 200, 200, 250],
        "Ugoira:FrameOffsets" => [0, 1679, 3588, 5189, 5989],
        "Ugoira:FrameCount" => 5,
        "Ugoira:FrameRate" => 4.761904761904762,
        "Ugoira:FrameMimeType" => "image/jpeg",
        "Ugoira:AnimationJsonFormat" => "none",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira zip file without an embedded animation.json file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/ugoira/ugoira.zip")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(6663, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("application/zip", file.mime_type)
      assert_equal("0d94800c4b520bf3d8adda08f95d31e2", file.md5)
      assert_equal("0d94800c4b520bf3d8adda08f95d31e2", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "ZIP:ZipRequiredVersion" => 20,
        "ZIP:ZipBitFlag" => 0,
        "ZIP:ZipCompression" => "None",
        "ZIP:ZipModifyDate" => "2014:10:05 23:31:06",
        "ZIP:ZipCRC" => "0x79484b64",
        "ZIP:ZipCompressedSize" => 1639,
        "ZIP:ZipUncompressedSize" => 1639,
        "ZIP:ZipFileName" => "000000.jpg",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira with PNG frames and a Danbooru-format animation.json" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/ugoira/ugoira-100260240-png-danbooru.zip")

      assert_equal(370, file.width)
      assert_equal(370, file.height)
      assert_equal(35_533, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("video/x-ugoira", file.mime_type)
      assert_equal("499aa4c49bb8facf5c616edde2e466dd", file.md5)
      assert_equal("b792fa7df8e3b4bd3f56bf1895393439", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.0, file.duration)
      assert_equal(8, file.frame_count)
      assert_equal(8.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "Ugoira:FrameDelays" => [125, 125, 125, 125, 125, 125, 125, 125],
        "Ugoira:FrameOffsets" => [0, 4271, 8565, 12_816, 17_110, 21_355, 25_639, 29_893],
        "Ugoira:FrameCount" => 8,
        "Ugoira:FrameRate" => 8.0,
        "Ugoira:FrameMimeType" => "image/png",
        "Ugoira:AnimationJsonFormat" => "Danbooru",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira with GIF frames and a Danbooru-format animation.json" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/ugoira/ugoira-108469527-gif-danbooru.zip")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(593_029, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("video/x-ugoira", file.mime_type)
      assert_equal("c45f3cc908c34357a8a39b442243ccb4", file.md5)
      assert_equal("befdac53c76715f6342e466a23ef3b9f", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(2.1, file.duration)
      assert_equal(30, file.frame_count)
      assert_equal(14.285714285714285, file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "Ugoira:FrameDelays" => [70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70],
        "Ugoira:FrameOffsets" => [0, 19_381, 38_354, 57_902, 76_592, 94_712, 113_933, 133_717, 153_662, 173_016, 193_274, 213_860, 234_407, 255_168, 275_935, 296_199, 315_983, 335_337, 355_391, 375_261, 394_544, 412_664, 431_296, 450_354, 469_391, 488_890, 509_036, 529_320, 549_509, 569_526],
        "Ugoira:FrameCount" => 30,
        "Ugoira:FrameRate" => 14.285714285714285,
        "Ugoira:FrameMimeType" => "image/gif",
        "Ugoira:AnimationJsonFormat" => "Danbooru",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira with JPEG frames and a Danbooru-format animation.json" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/ugoira/ugoira-95239241-danbooru.zip")

      assert_equal(384, file.width)
      assert_equal(384, file.height)
      assert_equal(79_865, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("video/x-ugoira", file.mime_type)
      assert_equal("72e8c2f6c6783efaeb4830d26ddfd17d", file.md5)
      assert_equal("68007e305a081faae3be65d3edbd4eb1", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.7, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(5.882352941176471, file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "Ugoira:FrameDelays" => [170, 170, 170, 170, 170, 170, 170, 170, 170, 170],
        "Ugoira:FrameOffsets" => [0, 7817, 15_616, 23_444, 31_274, 39_087, 46_931, 54_807, 62_599, 70_394],
        "Ugoira:FrameCount" => 10,
        "Ugoira:FrameRate" => 5.882352941176471,
        "Ugoira:FrameMimeType" => "image/jpeg",
        "Ugoira:AnimationJsonFormat" => "Danbooru",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira with a gallery-dl-format animation.json" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/ugoira/ugoira-95239241-gallery-dl.zip")

      assert_equal(384, file.width)
      assert_equal(384, file.height)
      assert_equal(79_276, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("video/x-ugoira", file.mime_type)
      assert_equal("7fe767b4e202415a2b2dec2a82be3b69", file.md5)
      assert_equal("68007e305a081faae3be65d3edbd4eb1", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.7, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(5.882352941176471, file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "Ugoira:FrameDelays" => [170, 170, 170, 170, 170, 170, 170, 170, 170, 170],
        "Ugoira:FrameOffsets" => [0, 7817, 15_616, 23_444, 31_274, 39_087, 46_931, 54_807, 62_599, 70_394],
        "Ugoira:FrameCount" => 10,
        "Ugoira:FrameRate" => 5.882352941176471,
        "Ugoira:FrameMimeType" => "image/jpeg",
        "Ugoira:AnimationJsonFormat" => "gallery-dl",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira zip without an embedded animation.json file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/ugoira/ugoira-95239241-pixiv.zip")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(41_048, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("application/zip", file.mime_type)
      assert_equal("36f8e63a70ce2f071d28b8b833e2a607", file.md5)
      assert_equal("36f8e63a70ce2f071d28b8b833e2a607", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "ZIP:ZipRequiredVersion" => 20,
        "ZIP:ZipBitFlag" => 0,
        "ZIP:ZipCompression" => "None",
        "ZIP:ZipModifyDate" => "2022:01:02 15:26:22",
        "ZIP:ZipCRC" => "0xb3600d17",
        "ZIP:ZipCompressedSize" => 4006,
        "ZIP:ZipUncompressedSize" => 4006,
        "ZIP:ZipFileName" => "000000.jpg",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira with a PixivToolkit-format animation.json" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/ugoira/ugoira-95239241-pixivtoolkit.zip")

      assert_equal(384, file.width)
      assert_equal(384, file.height)
      assert_equal(41_747, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("video/x-ugoira", file.mime_type)
      assert_equal("8d03702cc61e625b03cca3d556a163a1", file.md5)
      assert_equal("68007e305a081faae3be65d3edbd4eb1", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.7, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(5.882352941176471, file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "Ugoira:FrameDelays" => [170, 170, 170, 170, 170, 170, 170, 170, 170, 170],
        "Ugoira:FrameOffsets" => [639, 4685, 8713, 12_762, 16_808, 20_843, 24_901, 28_976, 33_011, 37_044],
        "Ugoira:FrameCount" => 10,
        "Ugoira:FrameRate" => 5.882352941176471,
        "Ugoira:FrameMimeType" => "image/jpeg",
        "Ugoira:AnimationJsonFormat" => "PixivToolkit",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira with a PixivUtil2-format animation.json" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/ugoira/ugoira-95239241-pixivutil2.zip")

      assert_equal(384, file.width)
      assert_equal(384, file.height)
      assert_equal(41_745, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("video/x-ugoira", file.mime_type)
      assert_equal("dbfe1d5764eb24f3d55224f85ef3383c", file.md5)
      assert_equal("68007e305a081faae3be65d3edbd4eb1", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.7, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(5.882352941176471, file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "Ugoira:FrameDelays" => [170, 170, 170, 170, 170, 170, 170, 170, 170, 170],
        "Ugoira:FrameOffsets" => [0, 4046, 8074, 12_123, 16_169, 20_204, 24_262, 28_337, 32_372, 36_405],
        "Ugoira:FrameCount" => 10,
        "Ugoira:FrameRate" => 5.882352941176471,
        "Ugoira:FrameMimeType" => "image/jpeg",
        "Ugoira:AnimationJsonFormat" => "PixivUtil2",
      }, file.metadata.to_h)
    end
  end

  context "an invalid ugoira zip file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/ugoira/invalid_ugoira.zip")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(181, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("application/zip", file.mime_type)
      assert_equal("482d731b98219d1d209ea81981ba4a1b", file.md5)
      assert_equal("482d731b98219d1d209ea81981ba4a1b", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "ZIP:ZipRequiredVersion" => 20,
        "ZIP:ZipBitFlag" => "0x0008",
        "ZIP:ZipCompression" => "Deflated",
        "ZIP:ZipModifyDate" => "2014:11:19 17:07:48",
        "ZIP:ZipCRC" => "0x32d70693",
        "ZIP:ZipCompressedSize" => 3,
        "ZIP:ZipUncompressedSize" => 1,
        "ZIP:ZipFileName" => "invalid_ugoira.txt",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira .zip file without an animation.json file but with separate frame delays" do
    setup do
      frame_delays = JSON.parse(File.read("test/files/ugoira/animation.json")).pluck("delay")
      @ugoira = MediaFile.open("test/files/ugoira/ugoira.zip", frame_delays: frame_delays)
    end

    should "convert to a webm" do
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
            zip.add(entry, "test/files/jpg/test.jpg")
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
            # XXX: x265 shipped by ubuntu does not have alpha support out of the box
            skip "Not supported due to ubuntu x265 compile flags" if format == :mp4 && codec == :hevc
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
            # XXX: x265 shipped by ubuntu does not have alpha support out of the box
            skip "Not supported due to ubuntu x265 compile flags" if format == :mp4 && codec == :hevc
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
