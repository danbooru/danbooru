require "test_helper"

class MediaFileArchiveTest < ActiveSupport::TestCase
  context "a ugoira packaged as a 7z archive" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/ugoira.7z")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(5016, file.file_size)
      assert_equal(:"7z", file.file_ext)
      assert_equal("application/octet-stream", file.mime_type)
      assert_equal("ffc17d70b1057e998352fb7ee0299bf2", file.md5)
      assert_equal("ffc17d70b1057e998352fb7ee0299bf2", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "7Z",
        "ZIP:FileVersion" => "7z v0.04",
        "ExifTool:Warning" => "Install Compress::Raw::Lzma to read encoded 7z information",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira packaged as a rar archive" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/ugoira.rar")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(6043, file.file_size)
      assert_equal(:rar, file.file_ext)
      assert_equal("application/octet-stream", file.mime_type)
      assert_equal("3af3859bd95b6d56ec6d135cca5b300e", file.md5)
      assert_equal("3af3859bd95b6d56ec6d135cca5b300e", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "RAR",
        "ZIP:FileVersion" => "RAR v5",
        "ZIP:CompressedSize" => 6,
        "ZIP:UncompressedSize" => 33_204,
        "ZIP:ModifyDate" => "2023:05:04 22:30:51+00:00",
        "ZIP:OperatingSystem" => "Unix",
        "ZIP:ArchivedFileName" => "000000.jpg",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira packaged as a tar archive" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/ugoira.tar")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(20_480, file.file_size)
      assert_equal(:bin, file.file_ext)
      assert_equal("application/octet-stream", file.mime_type)
      assert_equal("88983d058ba37f4754484e5bc7668300", file.md5)
      assert_equal("88983d058ba37f4754484e5bc7668300", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "TAR",
        "ExifTool:Warning" => "Unsupported file type",
      }, file.metadata.to_h)
    end
  end

  context "a ugoira packaged as a gzipped tar archive" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/ugoira.tar.gz")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(5151, file.file_size)
      assert_equal(:bin, file.file_ext)
      assert_equal("application/octet-stream", file.mime_type)
      assert_equal("4cad44838aa6e72f0e2bdc89696988e8", file.md5)
      assert_equal("4cad44838aa6e72f0e2bdc89696988e8", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "GZIP",
        "ZIP:Compression" => "Deflated",
        "ZIP:Flags" => "(none)",
        "ZIP:ModifyDate" => "0000:00:00 00:00:00",
        "ZIP:ExtraFlags" => "(none)",
        "ZIP:OperatingSystem" => "Unix",
      }, file.metadata.to_h)
    end
  end

  context "a zip bomb made of nested zip files" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/42.zip")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(42_838, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("application/zip", file.mime_type)
      assert_equal("1df9a18b18332f153918030b7b516615", file.md5)
      assert_equal("1df9a18b18332f153918030b7b516615", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "ZIP:ZipRequiredVersion" => 51,
        "ZIP:ZipBitFlag" => "0x0001",
        "ZIP:ZipCompression" => "Unknown (99)",
        "ZIP:ZipModifyDate" => "2000:03:28 21:40:54",
        "ZIP:ZipCRC" => "0x00000000",
        "ZIP:ZipCompressedSize" => 2524,
        "ZIP:ZipUncompressedSize" => 34_902,
        "ZIP:ZipFileName" => "lib 0.zip",
      }, file.metadata.to_h)
    end
  end

  context "a 7z archive containing a file with an absolute path" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/absolute-path.7z")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(106, file.file_size)
      assert_equal(:"7z", file.file_ext)
      assert_equal("application/octet-stream", file.mime_type)
      assert_equal("86f3d3d37e727b64bbecc0ef487f5ebf", file.md5)
      assert_equal("86f3d3d37e727b64bbecc0ef487f5ebf", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "7Z",
        "ZIP:FileVersion" => "7z v0.04",
        "ZIP:ModifyDate" => "2022:11:16 20:59:52+00:00",
        "ZIP:ArchivedFileName" => "/tmp/foo/foo.txt",
      }, file.metadata.to_h)
    end
  end

  context "a rar decompression bomb that expands to 1 GB" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/bomb-1-1G.rar")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(54_452, file.file_size)
      assert_equal(:rar, file.file_ext)
      assert_equal("application/octet-stream", file.mime_type)
      assert_equal("a794bc8353c311b7a4ab75bf28f728d5", file.md5)
      assert_equal("a794bc8353c311b7a4ab75bf28f728d5", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "RAR",
        "ZIP:FileVersion" => "RAR v5",
        "ZIP:CompressedSize" => 54_290,
        "ZIP:UncompressedSize" => 1_048_576_000,
        "ZIP:OperatingSystem" => "Unix",
        "ZIP:ArchivedFileName" => "1.txt",
      }, file.metadata.to_h)
    end
  end

  context "a rar decompression bomb with 100 files that each expand to 10 MB" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/bomb-100-10M.rar")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(61_529, file.file_size)
      assert_equal(:rar, file.file_ext)
      assert_equal("application/octet-stream", file.mime_type)
      assert_equal("24f862831e59276c188f20301f9bab53", file.md5)
      assert_equal("24f862831e59276c188f20301f9bab53", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "RAR",
        "ZIP:FileVersion" => "RAR v5",
        "ZIP:CompressedSize" => 566,
        "ZIP:UncompressedSize" => 10_485_760,
        "ZIP:OperatingSystem" => "Unix",
        "ZIP:ArchivedFileName" => "1.txt",
      }, file.metadata.to_h)
    end
  end

  context "a 7z archive containing 10,000 files" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/bomb-10k-files.7z")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(4678, file.file_size)
      assert_equal(:"7z", file.file_ext)
      assert_equal("application/octet-stream", file.mime_type)
      assert_equal("eedb0abf656b36a9eaf31bd4620b0688", file.md5)
      assert_equal("eedb0abf656b36a9eaf31bd4620b0688", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "7Z",
        "ZIP:FileVersion" => "7z v0.04",
        "ExifTool:Warning" => "Install Compress::Raw::Lzma to read encoded 7z information",
      }, file.metadata.to_h)
    end
  end

  context "a zip file with out-of-order central directory entries" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/out-of-order.zip")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(3318, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("application/zip", file.mime_type)
      assert_equal("fadbea08342a26b566f009c628c09d58", file.md5)
      assert_equal("fadbea08342a26b566f009c628c09d58", file.pixel_hash)
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
        "ZIP:ZipCompression" => "Deflated",
        "ZIP:ZipModifyDate" => "2018:04:19 00:35:16",
        "ZIP:ZipCRC" => "0x029dd9b7",
        "ZIP:ZipCompressedSize" => 405,
        "ZIP:ZipUncompressedSize" => 408,
        "ZIP:ZipFileName" => "9/10.gif",
      }, file.metadata.to_h)
    end
  end

  context "a zip file containing a symlink" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/symlink.zip")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(173, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("application/zip", file.mime_type)
      assert_equal("beda99e0114279e4c9d3670ce414b419", file.md5)
      assert_equal("beda99e0114279e4c9d3670ce414b419", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "ZIP:ZipRequiredVersion" => 10,
        "ZIP:ZipBitFlag" => 0,
        "ZIP:ZipCompression" => "None",
        "ZIP:ZipModifyDate" => "2022:11:16 14:51:38",
        "ZIP:ZipCRC" => "0x291fb90a",
        "ZIP:ZipCompressedSize" => 11,
        "ZIP:ZipUncompressedSize" => 11,
        "ZIP:ZipFileName" => "passwd",
      }, file.metadata.to_h)
    end
  end

  context "a zip file exploiting the zip-slip path traversal vulnerability" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/archive/zip-slip.zip")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(545, file.file_size)
      assert_equal(:zip, file.file_ext)
      assert_equal("application/zip", file.mime_type)
      assert_equal("c5c837b6bb679295a18733cb8f4a6b3a", file.md5)
      assert_equal("c5c837b6bb679295a18733cb8f4a6b3a", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "ZIP",
        "ZIP:ZipRequiredVersion" => 10,
        "ZIP:ZipBitFlag" => 0,
        "ZIP:ZipCompression" => "None",
        "ZIP:ZipModifyDate" => "2018:04:15 22:04:30",
        "ZIP:ZipCRC" => "0xf34f6f0f",
        "ZIP:ZipCompressedSize" => 19,
        "ZIP:ZipUncompressedSize" => 19,
        "ZIP:ZipFileName" => "good.txt",
      }, file.metadata.to_h)
    end
  end
end
