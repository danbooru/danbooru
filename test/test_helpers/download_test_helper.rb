module DownloadTestHelper
  def assert_downloaded(expected_filesize, source, referer = nil)
    strategy = Source::Extractor.find(source, referer)
    file = strategy.download_file!(strategy.image_urls.sole)
    assert_equal(expected_filesize, file.size, "Tested source URL: #{source}")
  end
end
