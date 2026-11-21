require "test_helper"
require "zip"

class DanbooruArchiveTest < ActiveSupport::TestCase
  context "MediaFile::Archive" do
    context ".open! method" do
      should "work without a block" do
        archive = MediaFile::Archive.open!("test/files/ugoira/ugoira.zip")
        assert_equal(5, archive.entries.count)
      end

      should "work with a block" do
        MediaFile::Archive.open!("test/files/ugoira/ugoira.zip") do |archive|
          assert_equal(5, archive.entries.count)
        end
      end

      should "raise an error if the block raises an error" do
        assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.open!("test/files/ugoira/ugoira.zip") { raise "failed" } }
      end

      should "raise an error if the file doesn't exist" do
        assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.open!("test/files/does_not_exist.zip") }
      end
    end

    context ".extract! method" do
      should "extract to temp directory if not given a block or directory" do
        dir, filenames = MediaFile::Archive.extract!("test/files/ugoira/ugoira.zip")

        assert_equal(true, File.directory?(dir))
        assert_equal(5, filenames.size)
        filenames.each_key { |filename| assert_equal(true, File.exist?(filename)) }
      ensure
        FileUtils.rm_rf(dir)
      end

      should "extract to a temp directory and delete it afterwards if given a block" do
        MediaFile::Archive.extract!("test/files/ugoira/ugoira.zip") do |dir, filenames|
          @tmpdir = dir
          assert_equal(true, File.directory?(dir))
          assert_equal(5, filenames.size)
          filenames.each_key { |filename| assert_equal(true, File.exist?(filename)) }
        end

        assert_equal(true, @tmpdir.present?)
        assert_equal(false, File.exist?(@tmpdir))
      end

      should "delete the temp directory if extracting the archive fails" do
        tmpdir = Dir.mktmpdir
        Dir.stubs(:mktmpdir).returns(tmpdir)

        assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.extract!("test/files/archive/long-path.tar.gz") }
        assert_equal(false, File.exist?(tmpdir))
      ensure
        FileUtils.rm_rf(tmpdir)
      end

      should "delete the temp directory if extracting is interrupted by an exception that isn't a StandardError" do
        tmpdir = Dir.mktmpdir
        Dir.stubs(:mktmpdir).returns(tmpdir)
        MediaFile::Archive.any_instance.stubs(:extract_to!).raises(Interrupt)
        archive = MediaFile::Archive.open!("test/files/ugoira/ugoira.zip")

        assert_raises(Interrupt) { archive.extract! }
        assert_equal(false, File.exist?(tmpdir))
      ensure
        FileUtils.rm_rf(tmpdir)
      end

      should "not delete the given directory if extracting the archive fails" do
        Dir.mktmpdir do |tmpdir|
          assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.extract!("test/files/archive/long-path.tar.gz", tmpdir) }
          assert_equal(true, File.exist?(tmpdir))
        end
      end

      should "extract to given directory if given a directory" do
        Dir.mktmpdir do |tmpdir|
          dir, filenames = MediaFile::Archive.extract!("test/files/ugoira/ugoira.zip", tmpdir)
          assert_equal(dir, tmpdir)
          assert_equal(5, filenames.size)
          filenames.each_key { |filename| assert_equal(true, File.exist?(filename)) }
        end
      end

      should "work with a .zip file" do
        MediaFile::Archive.extract!("test/files/ugoira/ugoira.zip") do |_dir, filenames|
          assert_equal(5, filenames.size)
          filenames.each_key { |filename| assert_equal(true, File.exist?(filename)) }
        end
      end

      should "work with a .rar file" do
        MediaFile::Archive.extract!("test/files/archive/ugoira.rar") do |_dir, filenames|
          assert_equal(5, filenames.size)
          filenames.each_key { |filename| assert_equal(true, File.exist?(filename)) }
        end
      end

      should "work with a .7z file" do
        MediaFile::Archive.extract!("test/files/archive/ugoira.7z") do |_dir, filenames|
          assert_equal(5, filenames.size)
          filenames.each_key { |filename| assert_equal(true, File.exist?(filename)) }
        end
      end

      should "keep non-ASCII filenames in a .zip with the UTF-8 filename flag" do
        # utf8-names.zip was written by hand to match the zips desktop zip tools make: the UTF-8 filename and data
        # descriptor flags (0x0808), Unix uid/gid and timestamp extra fields, and deflated data. It contains 原画.txt
        # ("hello\n") and 原画(1).txt ("world\n").
        assert_equal(%w[原画.txt 原画(1).txt], MediaFile::Archive.open!("test/files/archive/utf8-names.zip").entries.map(&:pathname))

        MediaFile::Archive.extract!("test/files/archive/utf8-names.zip") do |_dir, files|
          assert_equal(%w[原画.txt 原画(1).txt], files.values)
          assert_equal(%W[hello\n world\n], files.keys.map { File.read(it) })
        end
      end

      should "keep non-ASCII filenames in a .7z file" do
        # non-ascii-name.7z was created with `7z a non-ascii-name.7z テスト.txt`, where テスト.txt contains "hello".
        assert_equal(["テスト.txt"], MediaFile::Archive.open!("test/files/archive/non-ascii-name.7z").entries.map(&:pathname))

        MediaFile::Archive.extract!("test/files/archive/non-ascii-name.7z") do |_dir, files|
          assert_equal(["テスト.txt"], files.values)
          assert_equal("hello", File.read(files.keys.first))
        end
      end

      should "work with an archive containing directories" do
        MediaFile::Archive.extract!("test/files/archive/directory.zip") do |dir, files|
          assert_equal(%w[subdir/test.png test.png], files.values.sort)
          assert_equal(%W[#{dir}/000001 #{dir}/000002], files.keys.sort)
          files.each_key { |path| assert_equal(:png, MediaFile::FileTypeDetector.new(File.open(path)).file_ext) }
        end
      end
    end

    context "#uncompressed_size method" do
      should "work" do
        archive = MediaFile::Archive.open!("test/files/ugoira/ugoira.zip")
        assert_equal(6161, archive.uncompressed_size)
      end
    end

    context "#exists? method" do
      should "work" do
        archive = MediaFile::Archive.open!("test/files/ugoira/ugoira.zip")
        assert_equal(true, archive.exists? { |_entry, count| count > 4 })
      end
    end

    context "an unsupported archive format" do
      should "not be read" do
        assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.open!("test/files/archive/ugoira.tar").entries }
        assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.open!("test/files/archive/ugoira.tar.gz").entries }
        assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.open!("test/files/archive/long-path.tar.gz").extract! { nil } }
      end
    end

    context "a tar file with a zip file signature" do
      should "not be extracted" do
        archive = MediaFile::Archive.open!("test/files/archive/tar-disguised-as-ugoira.tar")

        assert_equal(:ugoira, archive.file_ext)
        assert_raises(MediaFile::Archive::Error) { archive.entries }
        assert_raises(MediaFile::Archive::Error) { archive.extract! { nil } }
      end
    end

    context "#file_ext method" do
      should "detect the file extension" do
        assert_equal(:zip, MediaFile::Archive.open!("test/files/ugoira/ugoira.zip").file_ext)
        assert_equal(:rar, MediaFile::Archive.open!("test/files/archive/ugoira.rar").file_ext)
        assert_equal(:"7z", MediaFile::Archive.open!("test/files/archive/ugoira.7z").file_ext)
        assert_equal(:bin, MediaFile::Archive.open!("test/files/archive/ugoira.tar").file_ext)
        assert_equal(:bin, MediaFile::Archive.open!("test/files/archive/ugoira.tar.gz").file_ext)
      end
    end

    should "detect directory traversal attacks" do
      archive = MediaFile::Archive.open!("test/files/archive/zip-slip.zip")

      assert_equal(true, archive.entries.any?(&:directory_traversal?))
      assert_raises(MediaFile::Archive::Error) { archive.extract! }
    end

    should "detect paths that are too long" do
      Dir.mktmpdir do |tmpdir|
        assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.extract!("test/files/archive/long-path.tar.gz", tmpdir) }
        assert_equal([], Dir.children(tmpdir))
      end
    end

    should "detect symlinks" do
      archive = MediaFile::Archive.open!("test/files/archive/symlink.zip")

      assert_equal(true, archive.entries.any? { |e| !e.file? && !e.directory? })
      assert_raises(MediaFile::Archive::Error) { archive.extract! }
    end

    should "not trust paths outside the directory from a compromised bin/archive" do
      Dir.mktmpdir do |dir|
        File.symlink("/etc/passwd", "#{dir}/link.jpg")

        ["/etc/passwd", "#{dir}/../../etc/passwd", "#{dir}/link.jpg", "#{dir}/missing.jpg"].each do |path|
          MediaFile::ExternalCommand.stubs(:run).returns([{ files: [path] }.to_json, nil])
          assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.extract!("test/files/ugoira/ugoira.zip", dir) }
        end
      end
    end

    should "extract to a directory whose path goes through a symlink" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p("#{dir}/real/extracted")
        File.symlink("#{dir}/real", "#{dir}/link")

        _dir, files = MediaFile::Archive.extract!("test/files/ugoira/ugoira.zip", "#{dir}/link/extracted")
        assert_equal(5, files.size)
        assert(files.keys.all? { File.readable?(it) })
      end
    end

    should "extract files with duplicate or overlapping names separately" do
      { %w[a/b.jpg a/.] => %w[a/b.jpg a], %w[a.jpg ./a.jpg] => %w[a.jpg a.jpg] }.each do |names, expected_names|
        MediaFile::Tempfile.create(["danbooru-archive-", ".zip"]) do |file|
          Zip::OutputStream.open(file.path) do |zip|
            names.each_with_index do |name, i|
              zip.put_next_entry(name)
              zip.write("data #{i}")
            end
          end

          MediaFile::Archive.extract!(file.path) do |_dir, files|
            assert_equal(expected_names, files.values)
            assert_equal(names.size.times.map { "data #{it}" }, files.keys.map { File.read(it) })
          end
        end
      end
    end

    should "not extract files with empty names" do
      [%w[.], [""], %w[a.jpg .]].each do |names|
        MediaFile::Tempfile.create(["danbooru-archive-", ".zip"]) do |file|
          Zip::OutputStream.open(file.path) do |zip|
            names.each do |name|
              zip.put_next_entry(name)
              zip.write("data")
            end
          end

          error = assert_raises(MediaFile::Archive::Error, names.inspect) { MediaFile::Archive.extract!(file.path) { nil } }
          assert_match(/\A'.*' has an empty path\z/, error.message)
        end
      end
    end

    should "raise an error for malformed output from a compromised bin/archive" do
      entry = { pathname: "a.jpg", pathname_too_long: false, size: 1, filetype: "file" }
      malformed = [
        "[]", { error: 1 }, { archives: nil }, { archives: [] }, { archives: [1] }, { archives: [{ error: 1 }] },
        { archives: [{ entries: nil }] }, { archives: [{ entries: [], extra: 1 }] },
        { archives: [{ entries: [entry.except(:size)] }] }, { archives: [{ entries: [entry.merge(extra: 1)] }] },
        { archives: [{ entries: [entry.merge(size: "1")] }] }, { archives: [{ entries: [entry.merge(size: -1)] }] },
        { archives: [{ entries: [entry.merge(filetype: "symlink")] }] }, { archives: [{ entries: [entry.merge(pathname_too_long: nil)] }] },
      ]

      malformed.each do |output|
        MediaFile::ExternalCommand.stubs(:run).returns([output.is_a?(String) ? output : output.to_json, nil])
        archive = MediaFile::Archive.open!("test/files/ugoira/ugoira.zip")

        assert_raises(MediaFile::Archive::Error, output.inspect) { archive.entries }
        assert_raises(MediaFile::Archive::Error, output.inspect) { archive.uncompressed_size }
      end

      MediaFile::ExternalCommand.stubs(:run).returns([{ archives: [{ entries: [entry] }] }.to_json, nil])
      assert_equal(1, MediaFile::Archive.open!("test/files/ugoira/ugoira.zip").uncompressed_size)
    end

    should "detect hardlinks" do
      # hardlink.rar is a RAR5 file written by hand, containing a.txt and b.jpg, a hardlink to /etc/passwd.
      archive = MediaFile::Archive.open!("test/files/archive/hardlink.rar")

      assert_equal([["a.txt", "file"], ["b.jpg", "other"]], archive.entries.map { [it.pathname, it.filetype] })
      error = assert_raises(MediaFile::Archive::Error) { archive.extract! }
      assert_equal("'b.jpg' is not a regular file", error.message)
    end

    should "detect absolute paths" do
      archive = MediaFile::Archive.open!("test/files/archive/absolute-path.7z")

      assert_equal(true, archive.entries.any? { |e| e.pathname.starts_with?("/") })
      assert_raises(MediaFile::Archive::Error) { archive.extract! }
    end

    should "stop listing archives with large numbers of files after the max entries" do
      archive = MediaFile::Archive.open!("test/files/archive/bomb-10k-files.7z", max_entries: 101)

      assert_equal(true, archive.exists? { |_, count| count > 100 })
      assert_equal(101, archive.file_count)
      assert_equal(101, archive.entries.size)
    end

    should "stop listing archives with large numbers of directories" do
      MediaFile::Tempfile.create(["danbooru-archive-", ".zip"]) do |file|
        Zip::OutputStream.open(file.path) do |zip|
          50.times { |n| zip.put_next_entry("dir#{n}/") }
          zip.put_next_entry("test.jpg")
          zip.write("data")
        end

        error = assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.open!(file.path, max_entries: 4).entries }
        assert_equal("too many files", error.message)
        assert_equal(1, MediaFile::Archive.open!(file.path, max_entries: 6).file_count)
      end
    end

    should "raise an error if extracting needs more memory than the limit" do
      # lzma2-4gb-dictionary.7z contains test.txt ("hello world" repeated 50 times). It was created with
      # `7z a -m0=lzma2 -mhc=off`, then edited to declare a 4 GB LZMA2 dictionary (property byte at offset 0x4e set to
      # 40), with the header CRCs updated.
      error = assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.open!("test/files/archive/lzma2-4gb-dictionary.7z").extract! { nil } }
      assert_equal("invalid or corrupt archive", error.message)
    end

    should "raise an error if listing the files takes too long" do
      stub_const(MediaFile::Archive, :LIST_TIMEOUT, 0.seconds) do
        error = assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.open!("test/files/ugoira/ugoira.zip").entries }
        assert_equal("timed out", error.message)
      end
    end

    should "raise an error if an extracted file is larger than the max file size" do
      MediaFile.config.stubs(:max_file_size).returns(1_000)

      assert_raises(MediaFile::Archive::Error) { MediaFile::Archive.extract!("test/files/ugoira/ugoira.zip") { nil } }
    end

    should "make extracted files readable even if the archive says they aren't" do
      MediaFile::Tempfile.create(["danbooru-archive-", ".zip"]) do |file|
        Zip::File.open(file.path, create: true) do |zip|
          entry = Zip::Entry.new(zip, "test.jpg")
          zip.add(entry, "test/files/jpg/test.jpg")
          entry.unix_perms = 0o000
        end

        MediaFile::Archive.extract!(file.path) do |_dir, filenames|
          assert_equal(0o600, File.stat(filenames.keys.first).mode & 0o777)
          assert_equal(File.binread("test/files/jpg/test.jpg"), File.binread(filenames.keys.first))
        end
      end
    end

    should "detect decompression bombs" do
      archive = MediaFile::Archive.open!("test/files/archive/bomb-1-1G.rar")

      assert_equal(1, archive.file_count)
      assert_equal(1_048_576_000, archive.uncompressed_size)
    end
  end
end
