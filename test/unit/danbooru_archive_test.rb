require 'test_helper'

class DanbooruArchiveTest < ActiveSupport::TestCase
  context "Danbooru::Archive" do
    context ".open! method" do
      should "work without a block" do
        archive = Danbooru::Archive.open!("test/files/ugoira.zip")
        assert_equal(5, archive.entries.count)
      end

      should "work with a block" do
        Danbooru::Archive.open!("test/files/ugoira.zip") do |archive|
          assert_equal(5, archive.entries.count)
        end
      end

      should "raise an error if the block raises an error" do
        assert_raises(Danbooru::Archive::Error) { Danbooru::Archive.open!("test/files/ugoira.zip") { raise "failed" } }
      end

      should "raise an error if the file doesn't exist" do
        assert_raises(Danbooru::Archive::Error) { Danbooru::Archive.open!("test/files/does_not_exist.zip") }
      end
    end

    context ".open method" do
      should "work without a block" do
        archive = Danbooru::Archive.open("test/files/ugoira.zip")
        assert_equal(5, archive.entries.count)
      end

      should "work with a block" do
        Danbooru::Archive.open("test/files/ugoira.zip") do |archive|
          assert_equal(5, archive.entries.count)
        end
      end

      should "return nil if the block raises an error" do
        assert_nil(Danbooru::Archive.open("test/files/ugoira.zip") { raise "failed" })
      end

      should "return nil if the file doesn't exist" do
        assert_nil(Danbooru::Archive.open("test/files/does_not_exist.zip"))
      end
    end

    context ".extract! method" do
      should "extract to temp directory if not given a block or directory" do
        dir, filenames = Danbooru::Archive.extract!("test/files/ugoira.zip")

        assert_equal(true, File.directory?(dir))
        assert_equal(5, filenames.size)
        filenames.each { |filename| assert_equal(true, File.exist?(filename)) }
      ensure
        FileUtils.rm_rf(dir)
      end

      should "extract to a temp directory and delete it afterwards if given a block" do
        Danbooru::Archive.extract!("test/files/ugoira.zip") do |dir, filenames|
          @tmpdir = dir
          assert_equal(true, File.directory?(dir))
          assert_equal(5, filenames.size)
          filenames.each { |filename| assert_equal(true, File.exist?(filename)) }
        end

        assert_equal(true, @tmpdir.present?)
        assert_equal(false, File.exist?(@tmpdir))
      end

      should "extract to given directory if given a directory" do
        Dir.mktmpdir do |tmpdir|
          dir, filenames = Danbooru::Archive.extract!("test/files/ugoira.zip", tmpdir)
          assert_equal(dir, tmpdir)
          assert_equal(5, filenames.size)
          filenames.each { |filename| assert_equal(true, File.exist?(filename)) }
        end
      end

      should "work with a .zip file" do
        Danbooru::Archive.extract!("test/files/archive/ugoira.zip") do |dir, filenames|
          assert_equal(5, filenames.size)
          filenames.each { |filename| assert_equal(true, File.exist?(filename)) }
        end
      end

      should "work with a .rar file" do
        Danbooru::Archive.extract!("test/files/archive/ugoira.rar") do |dir, filenames|
          assert_equal(5, filenames.size)
          filenames.each { |filename| assert_equal(true, File.exist?(filename)) }
        end
      end

      should "work with a .7z file" do
        Danbooru::Archive.extract!("test/files/archive/ugoira.7z") do |dir, filenames|
          assert_equal(5, filenames.size)
          filenames.each { |filename| assert_equal(true, File.exist?(filename)) }
        end
      end
    end

    context "#uncompressed_size method" do
      should "work" do
        archive = Danbooru::Archive.open!("test/files/ugoira.zip")
        assert_equal(6161, archive.uncompressed_size)
      end
    end

    context "#exists? method" do
      should "work" do
        archive = Danbooru::Archive.open!("test/files/ugoira.zip")
        assert_equal(true, archive.exists? { |entry, count| count > 4 })
      end
    end

    context "#format method" do
      should "detect the file type" do
        assert_equal("ZIP 2.0 (uncompressed)", Danbooru::Archive.open("test/files/archive/ugoira.zip").format)
        assert_equal("RAR5", Danbooru::Archive.open("test/files/archive/ugoira.rar").format)
        assert_equal("7-Zip", Danbooru::Archive.open("test/files/archive/ugoira.7z").format)
        assert_equal("GNU tar format", Danbooru::Archive.open("test/files/archive/ugoira.tar").format)
        assert_equal("GNU tar format", Danbooru::Archive.open("test/files/archive/ugoira.tar.gz").format)
      end
    end

    context "#file_ext method" do
      should "detect the file extension" do
        assert_equal(:zip, Danbooru::Archive.open("test/files/archive/ugoira.zip").file_ext)
        assert_equal(:rar, Danbooru::Archive.open("test/files/archive/ugoira.rar").file_ext)
        assert_equal(:"7z", Danbooru::Archive.open("test/files/archive/ugoira.7z").file_ext)
        assert_equal(:bin, Danbooru::Archive.open("test/files/archive/ugoira.tar").file_ext)
        assert_equal(:bin, Danbooru::Archive.open("test/files/archive/ugoira.tar.gz").file_ext)
      end
    end

    context "#ls method" do
      should "work" do
        archive = Danbooru::Archive.open!("test/files/ugoira.zip")
        output = StringIO.new

        archive.ls(output)
        assert_match(/^-rw-rw-r-- *0 0 *1639 2014-10-05 23:31:06 000000\.jpg$/, output.tap(&:rewind).read)
      end
    end

    should "detect directory traversal attacks" do
      archive = Danbooru::Archive.open!("test/files/archive/zip-slip.zip")

      assert_equal(true, archive.entries.any? { |e| e.directory_traversal? })
      assert_raises(Danbooru::Archive::Error) { archive.extract! }
    end

    should "detect symlinks" do
      archive = Danbooru::Archive.open!("test/files/archive/symlink.zip")

      assert_equal(true, archive.entries.any? { |e| !e.file? && !e.directory? })
      assert_raises(Danbooru::Archive::Error) { archive.extract! }
    end

    should "detect absolute paths" do
      archive = Danbooru::Archive.open!("test/files/archive/absolute-path.7z")

      assert_equal(true, archive.entries.any? { |e| e.pathname.starts_with?("/") })
      assert_raises(Danbooru::Archive::Error) { archive.extract! }
    end

    should "detect archives with large numbers of files" do
      archive = Danbooru::Archive.open!("test/files/archive/bomb-10k-files.7z")

      assert_equal(true, archive.exists? { |_, count| count > 100 })
      assert_equal(10_000, archive.file_count)
    end

    should "detect decompression bombs" do
      archive = Danbooru::Archive.open!("test/files/archive/bomb-1-1G.rar")

      assert_equal(1, archive.file_count)
      assert_equal(1_048_576_000, archive.uncompressed_size)
    end
  end
end
