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

  def assert_http_exists(url, headers: {})
    res = HTTParty.head(url, Danbooru.config.httparty_options.deep_merge(headers: headers))
    assert_equal(true, res.success?)
  end

  def assert_http_status(code, url, headers: {})
    res = HTTParty.head(url, Danbooru.config.httparty_options.deep_merge(headers: headers))
    assert_equal(code, res.code)
  end

  def assert_http_size(size, url, headers: {})
    res = HTTParty.head(url, Danbooru.config.httparty_options.deep_merge(headers: headers))
    assert_equal(size, res.content_length)
  end
end
