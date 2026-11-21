require "test_helper"
require "vips"
require "zip"

class MediaFileUgoiraTest < ActiveSupport::TestCase
  def create_ugoira_zip(file, frame_count: 2, compression_method: Zip::Entry::STORED, frame_data: File.binread("test/files/jpg/test.jpg"), animation_json: nil)
    Zip::File.open(file.path, create: true, suppress_extra_fields: true) do |zip|
      frames = frame_count.times.map { |n| { file: "#{"%06d" % n}.jpg", delay: 100 } }
      zip.get_output_stream(Zip::Entry.new(zip, "animation.json", compression_method: Zip::Entry::STORED)) { |f| f.write(animation_json || frames.to_json) }

      frames.each do |frame|
        zip.get_output_stream(Zip::Entry.new(zip, frame[:file], compression_method:)) { |f| f.write(frame_data) }
      end
    end

    file.reopen(file.path, "rb")
  end

  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "ugoira",
        "test/files/ugoira/invalid_ugoira.zip" => nil,
        "test/files/ugoira/ugoira-100260240-png-danbooru.zip" => [150, 150, "68a853d1ca13b8b7c7af8e2df9f244e5"],
        "test/files/ugoira/ugoira-108469527-gif-danbooru.zip" => [150, 150, "1a01cbaecaa2bbad30ea4c41c490c727"],
        "test/files/ugoira/ugoira-95239241-danbooru.zip" => [150, 150, "952e9401c2268a7cb32d668f5c7db82e"],
        "test/files/ugoira/ugoira-95239241-gallery-dl.zip" => [150, 150, "952e9401c2268a7cb32d668f5c7db82e"],
        "test/files/ugoira/ugoira-95239241-pixiv.zip" => nil,
        "test/files/ugoira/ugoira-95239241-pixivtoolkit.zip" => [150, 150, "952e9401c2268a7cb32d668f5c7db82e"],
        "test/files/ugoira/ugoira-95239241-pixivutil2.zip" => [150, 150, "952e9401c2268a7cb32d668f5c7db82e"],
        "test/files/ugoira/ugoira-compressed.zip" => nil,
        "test/files/ugoira/ugoira.zip" => nil,
      )
    end
  end

  context "a ugoira zip file" do
    should "be parsed correctly" do
      frame_delays = MediaFile.parse_json(File.read("test/files/ugoira/animation.json")).pluck("delay")
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

    should "close its webm when it's closed" do
      path = @ugoira.webm.path
      @ugoira.close

      assert_equal(false, File.exist?(path))
    end

    should "delete the output file if the conversion fails" do
      output_file = MediaFile::Tempfile.new
      path = output_file.path
      MediaFile::FFmpeg.stubs(:encode_images!).raises(MediaFile::FFmpeg::Error)

      assert_raises(MediaFile::FFmpeg::Error) { @ugoira.convert(output_file:) }
      assert_equal(false, File.exist?(path))
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
      MediaFile::Archive.extract!("test/files/ugoira/ugoira.zip") do |tmpdir|
        frame_delays = MediaFile.parse_json(File.read("test/files/ugoira/animation.json")).pluck("delay")
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
      MediaFile::Archive.extract!("test/files/ugoira/ugoira-95239241-gallery-dl.zip") do |tmpdir, extracted_files|
        # Archives are extracted to numbered files, so give them their names back to unpack the ugoira.
        extracted_files.each { |path, name| File.rename(path, "#{tmpdir}/#{name}") }
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
      MediaFile::Tempfile.create(["danbooru-ugoira-zip64-", ".zip"]) do |file|
        Zip::File.open(file.path, create: true, compression_level: 0) do |zip|
          %w[000000.jpg 000001.jpg].each do |name|
            entry = Zip::Entry.new(zip, name)
            entry.extra.create(:zip64)
            zip.add(entry, "test/files/jpg/test.jpg")
          end
        end

        MediaFile::Ugoira.open(file.path, frame_delays: [100, 100]) do |ugoira|
          assert_equal("invalid zip file", ugoira.error)
        end
      end
    end
  end

  context "a ugoira zip with an invalid structure" do
    should "be rejected without extracting a compressed file" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        create_ugoira_zip(file, compression_method: Zip::Entry::DEFLATED)

        MediaFile.open(file) do |ugoira|
          assert_kind_of(MediaFile::Ugoira, ugoira)
          assert_equal("ugoira must not be compressed", ugoira.error)
          assert_equal([], Dir.children(ugoira.tmpdir.path))
          assert_raises(MediaFile::Ugoira::InvalidUgoiraError) { ugoira.dimensions }
        end
      end
    end

    should "be rejected without extracting a file with too many frames" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        create_ugoira_zip(file, frame_count: 501)

        MediaFile.open(file) do |ugoira|
          assert_equal("cannot have more than 500 frames", ugoira.error)
          assert_equal([], Dir.children(ugoira.tmpdir.path))
          assert_raises(MediaFile::Ugoira::InvalidUgoiraError) { ugoira.frames }
        end
      end
    end

    should "be rejected without extracting a disguised nested Ugoira frame" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |inner|
        MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |outer|
          create_ugoira_zip(inner)
          create_ugoira_zip(outer, frame_data: inner.read)

          MediaFile.open(outer) do |ugoira|
            assert_equal("file '000000.jpg' is not an image file", ugoira.error)
            assert_equal([], Dir.children(ugoira.tmpdir.path))
            assert_raises(MediaFile::Ugoira::InvalidUgoiraError) { ugoira.dimensions }
          end
        end
      end
    end

    should "be rejected without extracting a disguised SWF frame" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        create_ugoira_zip(file, frame_data: File.binread("test/files/swf/compressed.swf"))

        MediaFile.open(file) do |ugoira|
          MediaFile::ExifTool.any_instance.expects(:metadata).never

          assert_equal("file '000000.jpg' is not an image file", ugoira.error)
          assert_equal([], Dir.children(ugoira.tmpdir.path))
          assert_raises(MediaFile::Ugoira::InvalidUgoiraError) { ugoira.dimensions }
        end
      end
    end

    should "be rejected without extracting a disguised PNG frame" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        create_ugoira_zip(file, frame_data: File.binread("test/files/png/test.png"))

        MediaFile.open(file) do |ugoira|
          assert_equal("file '000000.jpg' has the wrong file extension (expected '000000.png')", ugoira.error)
          assert_equal([], Dir.children(ugoira.tmpdir.path))
          assert_raises(MediaFile::Ugoira::InvalidUgoiraError) { ugoira.dimensions }
        end
      end
    end

    should "be rejected without extracting a disguised GIF frame" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        create_ugoira_zip(file, frame_data: File.binread("test/files/gif/test-static-32x32.gif"))

        MediaFile.open(file) do |ugoira|
          assert_equal("file '000000.jpg' has the wrong file extension (expected '000000.gif')", ugoira.error)
          assert_equal([], Dir.children(ugoira.tmpdir.path))
          assert_raises(MediaFile::Ugoira::InvalidUgoiraError) { ugoira.dimensions }
        end
      end
    end

    should "be rejected without extracting a disguised MP4 frame" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        create_ugoira_zip(file, frame_data: File.binread("test/files/mp4/test-300x300.mp4"))

        MediaFile.open(file) do |ugoira|
          MediaFile::FFmpeg.expects(:shell!).never

          assert_equal("file '000000.jpg' is not an image file", ugoira.error)
          assert_equal([], Dir.children(ugoira.tmpdir.path))
          assert_raises(MediaFile::Ugoira::InvalidUgoiraError) { ugoira.dimensions }
        end
      end
    end

    should "be rejected without extracting a disguised WebM frame" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        create_ugoira_zip(file, frame_data: File.binread("test/files/webm/test-512x512.webm"))

        MediaFile.open(file) do |ugoira|
          MediaFile::FFmpeg.expects(:shell!).never

          assert_equal("file '000000.jpg' is not an image file", ugoira.error)
          assert_equal([], Dir.children(ugoira.tmpdir.path))
          assert_raises(MediaFile::Ugoira::InvalidUgoiraError) { ugoira.dimensions }
        end
      end
    end

    should "be rejected without extracting a frame hidden inside another frame" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        jpg = File.binread("test/files/jpg/test.jpg")
        mp4 = File.binread("test/files/mp4/test-300x300.mp4")
        hidden_header = [0x04034b50, 20, 0, 0, 0, 33, Zlib.crc32(mp4), mp4.bytesize, mp4.bytesize, 10, 0].pack("VvvvvvVVVvv") << "000001.jpg"
        json = [{ file: "000000.jpg", delay: 100 }, { file: "000001.jpg", delay: 100 }].to_json
        hidden_offset = (30 + "animation.json".size + json.size) + (30 + "000000.jpg".size) + jpg.size

        # The central directory points 000001.jpg at an MP4 hidden inside 000000.jpg, while the local headers are
        # followed by a JPEG-looking decoy that claims the MP4's CRC.
        write_raw_zip(file, [
          { name: "animation.json", data: json },
          { name: "000000.jpg", data: jpg + hidden_header + mp4 },
          { name: "000001.jpg", data: "\xff\xd8".b + ("\0".b * (mp4.size - 2)), crc: Zlib.crc32(mp4), offset: hidden_offset },
        ])

        MediaFile.open(file.path) do |ugoira|
          assert_equal("invalid zip file", ugoira.error)
          assert_equal([], Dir.children(ugoira.tmpdir.path))
        end
      end
    end

    should "truncate long file names in the error message" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        jpg = File.binread("test/files/jpg/test.jpg")
        write_raw_zip(file, [{ name: "#{"a" * 5000}.jpg", data: jpg }, { name: "000001.jpg", data: jpg }])

        MediaFile.open(file.path, frame_delays: [100, 100]) do |ugoira|
          assert_operator(ugoira.error.size, :<=, 1000)
          assert_match(/\Afile 'aaaa.*\.\.\.\z/, ugoira.error)
        end
      end
    end

    should "be rejected if a file name isn't valid UTF-8" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        jpg = File.binread("test/files/jpg/test.jpg")
        write_raw_zip(file, [{ name: "\xff.jpg".b, data: jpg }, { name: "000001.jpg", data: jpg }])

        MediaFile.open(file.path, frame_delays: [100, 100]) do |ugoira|
          assert_equal("file '?.jpg' has invalid name (expected '000000.jpg')", ugoira.error)
        end
      end
    end

    should "not trust invalid frame data from a compromised bin/archive" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        create_ugoira_zip(file)

        # Run bin/archive for real, then tamper with its output.
        [[{}, nil], [{ files: ["/etc/passwd"] }, "invalid zip file"], [{ names: ["000000.jpg", "../x", "animation.json"] }, "invalid zip file"], [{ frame_offsets: ["0", 1] }, "invalid zip file"], [{ frame_offsets: [0, 2**40] }, "invalid zip file"], [{ frame_offsets: [0] * 1000 }, "invalid zip file"]].each do |tampered, expected_error|
          MediaFile.open(file.path) do |ugoira|
            output = MediaFile::Archive.run!("ugoira", file.path, ugoira.tmpdir.path, read: [file.path], write: [ugoira.tmpdir.path])
            MediaFile::Archive.stubs(:run!).returns(output.merge(tampered.stringify_keys))

            expected_error.nil? ? assert_nil(ugoira.error) : assert_equal(expected_error, ugoira.error)
            MediaFile::Archive.unstub(:run!)
          end
        end
      end
    end

    should "be rejected if a file has an invalid CRC" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        create_ugoira_zip(file)
        data = File.binread(file.path)
        offset = data.index("\xff\xd8".b) + 100
        File.binwrite(file.path, (data.getbyte(offset) ^ 0xff).chr, offset)

        MediaFile.open(file.path) do |ugoira|
          assert_equal("invalid zip file", ugoira.error)
          assert_equal([], Dir.children(ugoira.tmpdir.path))
        end
      end
    end

    should "be rejected if it has no frames" do
      MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
        create_ugoira_zip(file, frame_count: 0)

        MediaFile.open(file.path) do |ugoira|
          assert_equal([0, 0], ugoira.dimensions)
          assert_equal("must have at least two frames", ugoira.error)
          assert_equal(true, ugoira.is_corrupt?)
        end
      end
    end

    should "be rejected if animation.json has frames that aren't objects" do
      ["[1, 2]", "[null, null]", '{"frames": ["a", "b"]}', '{"ugokuIllustData": {"frames": [1, 2]}}'].each do |animation_json|
        MediaFile::Tempfile.create(["danbooru-ugoira-", ".zip"]) do |file|
          create_ugoira_zip(file, animation_json:)

          MediaFile.open(file.path) do |ugoira|
            assert_equal("unrecognized animation.json format", ugoira.error)
            assert_equal(true, ugoira.is_corrupt?)
          end
        end
      end
    end

    should "be rejected if it's a tar file disguised as a zip file" do
      MediaFile.open("test/files/archive/tar-disguised-as-ugoira.tar") do |ugoira|
        assert_instance_of(MediaFile::Ugoira, ugoira)
        assert_equal("invalid zip file", ugoira.error)
      end
    end
  end

  context "a ugoira with frames of different dimensions" do
    should "be rejected before decoding the frames" do
      MediaFile::Image.any_instance.stubs(:dimensions).returns([384, 384]).then.returns([50_000, 50_000])
      MediaFile::Image.any_instance.expects(:is_corrupt?).never

      MediaFile.open("test/files/ugoira/ugoira-95239241-danbooru.zip") do |ugoira|
        assert_equal("frames must have the same dimensions", ugoira.error)
      end
    end
  end

  context "a ugoira with frames of different sizes" do
    should "be rejected without decoding any frames" do
      Dir.mktmpdir do |dir|
        Vips::Image.black(64, 64).jpegsave("#{dir}/0.jpg")
        Vips::Image.black(128, 128).jpegsave("#{dir}/1.jpg")
        ugoira = MediaFile::Ugoira.new(["#{dir}/0.jpg", "#{dir}/1.jpg"], frame_delays: [100, 100])

        assert_equal("frames must have the same dimensions", ugoira.error)
        assert_equal(ugoira.frames.map(&:md5), ugoira.frames.map(&:pixel_hash))
        ugoira.close
      end
    end
  end

  context "a ugoira with a frame that's too large to decode" do
    should "be rejected as too large, not corrupt, and name the frame that's too large" do
      Dir.mktmpdir do |dir|
        image = Vips::Image.black(64, 64)
        image.jpegsave("#{dir}/0.jpg")
        image.jpegsave("#{dir}/1.jpg", interlace: true)
        ugoira = MediaFile::Ugoira.new(["#{dir}/0.jpg", "#{dir}/1.jpg"], frame_delays: [100, 100])

        stub_const(MediaFile::Image, :MAX_IN_MEMORY_SIZE, 1) do
          assert_equal("file '1.jpg' is too large to decode", ugoira.error)
        end

        ugoira.close
      end
    end
  end

  context "Conversion of a large ugoira" do
    should "not limit encoding to the default command timeout" do
      Dir.mktmpdir do |dir|
        # Random noise is slow to encode, so encoding these frames takes about 7s.
        frames = 30.times.map do |i|
          Vips::Image.gaussnoise(960, 540, mean: 128, sigma: 40).jpegsave("#{dir}/#{i}.jpg")
          Pathname("#{dir}/#{i}.jpg")
        end

        stub_const(MediaFile::ExternalCommand, :TIMEOUT, 2.seconds) do
          video = MediaFile::Ugoira.new(frames, frame_delays: [100] * 30).convert
          assert_equal(30, video.frame_count)
        end
      end
    end

    should "not limit the first pass of two-pass encoding to the default command timeout" do
      MediaFile::Image.stubs(:read!)
      MediaFile::Image.any_instance.stubs(:dimensions).returns([500, 335])
      MediaFile::ExternalCommand.expects(:run).with(regexp_matches(/ -pass 1 /), has_entry(:timeout, MediaFile::FFmpeg::ENCODE_TIMEOUT)).raises(MediaFile::TimeoutError, "pass 1 timed out")
      ugoira = MediaFile::Ugoira.new(["test/files/jpg/test.jpg", "test/files/jpg/test.jpg"], frame_delays: [100, 100])

      error = assert_raises(MediaFile::FFmpeg::Error) { ugoira.convert(format: :webm) }
      assert_equal("pass 1 timed out", error.message)
      ugoira.close
    end
  end

  context "Conversion of a ugoira with a frame disguised as a playlist" do
    should "not let the frame make ffmpeg read other files" do
      Dir.mktmpdir do |dir|
        FileUtils.cp("test/files/jpg/test.jpg", "#{dir}/0.jpg")
        File.write("#{dir}/1.jpg", "ffconcat version 1.0\nfile 0.jpg\nfile 0.jpg\nfile 0.jpg\n")

        ugoira = MediaFile::Ugoira.new(["#{dir}/0.jpg", "#{dir}/1.jpg"], frame_delays: [100, 100])
        ugoira.frames.last.stubs(:file_ext).returns(:jpg)

        error = assert_raises(MediaFile::FFmpeg::Error) { ugoira.convert }
        assert_match(/\Affmpeg failed/, error.message)
        ugoira.close
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

  context "Validating a ugoira" do
    should "pass for a valid ugoira" do
      MediaFile.open("test/files/ugoira/ugoira-95239241-danbooru.zip") { |ugoira| assert_nothing_raised { ugoira.validate! } }
    end

    should "fail with a message for users for an invalid zip file" do
      MediaFile.open("test/files/ugoira/invalid_ugoira.zip", frame_delays: [100, 100]) do |ugoira|
        error = assert_raises(MediaFile::InvalidFileError) { ugoira.validate! }
        assert_equal("invalid zip file", error.user_message)
      end
    end
  end
end
