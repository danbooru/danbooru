module DownloadTestHelper
  def assert_downloaded(expected_filesize, source)
    tempfile = Tempfile.new("danbooru-test")
    download = Downloads::File.new(source, tempfile.path)

    assert_nothing_raised(Downloads::File::Error) do
      download.download!
    end

    assert_equal(expected_filesize, tempfile.size, "Tested source URL: #{source}")
  end

  def assert_rewritten(expected_source, test_source)
    tempfile = Tempfile.new("danbooru-test")
    download = Downloads::File.new(test_source, tempfile.path)

    rewritten_source, _, _ = download.before_download(test_source, {})
    assert_match(expected_source, rewritten_source, "Tested source URL: #{test_source}")
  end

  def assert_not_rewritten(source)
    assert_rewritten(source, source)
  end
end
