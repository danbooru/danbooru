require "test_helper"

class MediaFileCliTest < ActiveSupport::TestCase
  def run_cli(*args)
    stdout = StringIO.new
    stderr = StringIO.new
    result = MediaFile::CLI.run!(*args, stdout:, stderr:)

    [result, stdout.string, stderr.string]
  end

  context "CLI" do
    should "work when called with bin/media-cli" do
      assert_equal(true, system("bin/media-cli --help > /dev/null 2>&1"))
    end

    should "print the list of commands" do
      result, stdout, _stderr = run_cli("--help")
      assert_equal(true, result)
      assert_match(/^  analyze /, stdout)
      assert_match(/^  doctor /, stdout)

      result, stdout, _stderr = run_cli
      assert_equal(false, result)
      assert_match(/^Usage: media-cli/, stdout)
    end

    should "fail for an unknown command" do
      result, _stdout, stderr = run_cli("nope")

      assert_equal(false, result)
      assert_match(/\Aunknown command: nope/, stderr)
    end

    should "fail for an invalid option" do
      result, _stdout, stderr = run_cli("validate", "--nope", "test/files/jpg/test.jpg")

      assert_equal(false, result)
      assert_match(/invalid option: --nope/, stderr)
    end
  end

  context "The analyze command" do
    should "work" do
      assert_equal(true, run_cli("analyze", "--help").first)
      assert_equal(false, run_cli("analyze", "--invalid-option").first)

      assert_equal(true, run_cli(*%w[analyze test/files]).first)
      assert_equal(true, run_cli(*%w[analyze test/files -lh -u si -p 3]).first)
      assert_equal(true, run_cli(*%w[analyze test/files -lR]).first)
      assert_equal(true, run_cli(*%w[analyze test/files/jpg/test.jpg]).first)
      assert_equal(true, run_cli(*%w[analyze test/files/jpg/test.jpg -d]).first)
      assert_equal(true, run_cli(*%w[analyze test/files/ -c mpixels,name -g type,dimensions -s user,size]).first)
    end

    should "produce json output" do
      result, stdout, _stderr = run_cli(*%w[analyze test/files/jpg/test.jpg -j -c name,size])

      assert_equal(true, result)
      assert_equal([{ "name" => "test.jpg", "size" => 28_086 }], MediaFile.parse_json(stdout))
    end
  end

  context "The validate command" do
    should "print ok for valid files" do
      result, stdout, _stderr = run_cli("validate", "test/files/jpg/test.jpg", "test/files/png/test.png")

      assert_equal(true, result)
      assert_equal("test/files/jpg/test.jpg: ok\ntest/files/png/test.png: ok\n", stdout)
    end

    should "print why invalid files are invalid" do
      result, stdout, _stderr = run_cli("validate", "test/files/jpg/test.jpg", "test/files/jpg/test-corrupt.jpg")

      assert_equal(false, result)
      assert_equal("test/files/jpg/test.jpg: ok\ntest/files/jpg/test-corrupt.jpg: File is corrupt\n", stdout)
    end

    should "use the max duration" do
      result, stdout, _stderr = run_cli("validate", "--max-duration=4", "test/files/mp4/test-300x300-av1.mp4")

      assert_equal(false, result)
      assert_equal("test/files/mp4/test-300x300-av1.mp4: Duration must be less than 4 seconds\n", stdout)
    end

    should "fail without any files" do
      result, _stdout, stderr = run_cli("validate")

      assert_equal(false, result)
      assert_match(/no files given/, stderr)
    end
  end

  context "The preview command" do
    should "write a preview of the file" do
      Dir.mktmpdir do |dir|
        output = "#{dir}/preview.webp"
        result, stdout, _stderr = run_cli("preview", "-s", "100x100", "-f", "webp", "-o", output, "test/files/jpg/test.jpg")

        assert_equal(true, result)
        assert_equal("#{output}: 100x67\n", stdout)
        MediaFile.open(output) do |preview|
          assert_equal(:webp, preview.file_ext)
          assert_equal([100, 67], preview.dimensions)
        end
      end
    end

    should "write a preview of a video" do
      Dir.mktmpdir do |dir|
        output = "#{dir}/preview.jpg"
        result, _stdout, _stderr = run_cli("preview", "-o", output, "test/files/mp4/test-300x300-av1.mp4")

        assert_equal(true, result)
        MediaFile.open(output) { |preview| assert_equal([150, 150], preview.dimensions) }
      end
    end
  end

  context "The convert command" do
    should "convert a ugoira to a video" do
      Dir.mktmpdir do |dir|
        output = "#{dir}/out.webm"
        result, stdout, _stderr = run_cli("convert", "-o", output, "test/files/ugoira/ugoira-95239241-danbooru.zip")

        assert_equal(true, result)
        assert_match(/\A#{Regexp.escape(output)} - \d+x\d+ /, stdout)
        MediaFile.open(output) { |video| assert_equal(:webm, video.file_ext) }
      end
    end

    should "fail for a file that isn't a ugoira" do
      result, _stdout, stderr = run_cli("convert", "test/files/jpg/test.jpg")

      assert_equal(false, result)
      assert_match(%r{test/files/jpg/test\.jpg isn't a ugoira}, stderr)
    end
  end

  context "The hash command" do
    should "print the MD5 and pixel hash of each file" do
      result, stdout, _stderr = run_cli("hash", "test/files/jpg/test.jpg")

      assert_equal(true, result)
      assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76 01cb481ec7730b7cfced57ffa5abd196 test/files/jpg/test.jpg\n", stdout)
    end
  end

  context "The archive command" do
    should "list the files in a valid archive" do
      result, stdout, _stderr = run_cli("archive", "test/files/archive/ugoira.7z")

      assert_equal(true, result)
      assert_match(/^file +\d+ 000000\.jpg$/, stdout)
      assert_match(%r{^test/files/archive/ugoira\.7z: ok$}, stdout)
    end

    should "print why an invalid archive is invalid" do
      result, stdout, _stderr = run_cli("archive", "test/files/archive/symlink.zip")

      assert_equal(false, result)
      assert_match(%r{^test/files/archive/symlink\.zip: 'passwd' in 'symlink\.zip' isn't a regular file$}, stdout)
    end
  end

  context "The doctor command" do
    should "print the versions of the programs the library uses" do
      result, stdout, _stderr = run_cli("doctor")

      assert_equal(true, result)
      assert_match(/^ffmpeg: \d/, stdout)
      assert_match(/^exiftool: \d/, stdout)
      assert_match(/^sandbox: enabled$/, stdout)
    end

    should "fail if a program isn't installed" do
      MediaFile.stubs(:dependency_versions).returns({ vips: "8.18.7", ffmpeg: "9.0.2", mkvmerge: nil, exiftool: "13.55" })
      result, stdout, _stderr = run_cli("doctor")

      assert_equal(false, result)
      assert_match(/^mkvmerge: not installed$/, stdout)
    end

    should "report that the sandbox is disabled when MEDIA_FILE_DISABLE_SANDBOX is set" do
      output = IO.popen({ "MEDIA_FILE_DISABLE_SANDBOX" => "true" }, ["bin/media-cli", "doctor"], err: File::NULL, &:read)

      assert_match(/^sandbox: disabled$/, output)
    end
  end
end
