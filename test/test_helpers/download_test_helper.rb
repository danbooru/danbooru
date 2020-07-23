module DownloadTestHelper
  def assert_downloaded(expected_filesize, source, referer = nil)
    strategy = Sources::Strategies.find(source, referer)
    file = strategy.download_file!
    assert_equal(expected_filesize, file.size, "Tested source URL: #{source}")
  end

  def assert_rewritten(expected_source, test_source, test_referer = nil)
    strategy = Sources::Strategies.find(test_source, test_referer)
    rewritten_source = strategy.image_url
    assert_match(expected_source, rewritten_source, "Tested source URL: #{test_source}")
  end

  def assert_not_rewritten(source, referer = nil)
    assert_rewritten(source, source, referer)
  end
end
