module DownloadTestHelper
  def assert_downloaded(expected_filesize, source)
    assert_nothing_raised(Downloads::File::Error) do
      tempfile = Downloads::File.new(source).download!
      assert_equal(expected_filesize, tempfile.size, "Tested source URL: #{source}")
      tempfile.close!
    end
  end

  def assert_rewritten(expected_source, test_source)
    download = Downloads::File.new(test_source)

    rewritten_source, _, _ = download.before_download(test_source, {})
    assert_match(expected_source, rewritten_source, "Tested source URL: #{test_source}")
  end

  def assert_not_rewritten(source)
    assert_rewritten(source, source)
  end
end
