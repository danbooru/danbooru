require 'ptools'

module DownloadTestHelper
  def assert_downloaded(expected_filesize, source)
    download = Downloads::File.new(source)
    tempfile = download.download!
    assert_equal(expected_filesize, tempfile.size, "Tested source URL: #{source}")
  rescue Net::OpenTimeout
    skip "Remote connection to #{source} failed"
  end

  def assert_rewritten(expected_source, test_source)
    download = Downloads::File.new(test_source)

    rewritten_source, _, _ = download.before_download(test_source, {})
    assert_match(expected_source, rewritten_source, "Tested source URL: #{test_source}")
  end

  def assert_not_rewritten(source)
    assert_rewritten(source, source)
  end

  def check_ffmpeg
    File.which("ffmpeg") && File.which("mkvmerge")
  end
end