require 'ptools'

module DownloadTestHelper
  def assert_downloaded(expected_filesize, source, referer=nil)
    download = Downloads::File.new(source, referer)
    tempfile, strategy = download.download!
    assert_equal(expected_filesize, tempfile.size, "Tested source URL: #{source}")
  rescue Net::OpenTimeout
    skip "Remote connection to #{source} failed"
  end

  def assert_rewritten(expected_source, test_source, test_referer=nil)
    strategy = Sources::Strategies.find(test_source, test_referer)
    rewritten_source = strategy.image_url
    assert_match(expected_source, rewritten_source, "Tested source URL: #{test_source}")
  end

  def assert_not_rewritten(source, referer=nil)
    assert_rewritten(source, source, referer)
  end

  def check_ffmpeg
    File.which("ffmpeg") && File.which("mkvmerge")
  end
end