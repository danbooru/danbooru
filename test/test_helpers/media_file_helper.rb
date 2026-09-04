module MediaFileTestHelper
  # Test thumbnail generation: assert that the 150x150 preview generated for every file in test/files/<file_type>
  # stays the same across dependency updates, or nil for files that are expected to fail to generate a preview at all.
  #
  # This helps us discover changes to thumbnail generation early.
  #
  # `hashes` must cover every file in test/files/<file_type>; this is checked so that new fixture files don't
  # silently go untested. If a file is missing, the failure message prints a ready-to-paste line for it.
  #
  # @param file_type [String] the directory under test/files/ to glob (e.g. "png", "mp4")
  # @param hashes [Hash<String, Array<(Integer, Integer, String)>, nil>] a map of file name to [width, height,
  #   pixel hash], or nil if the file is expected to fail to generate a preview
  def should_generate_previews(file_type, hashes)
    call_location = caller_locations.find { |loc| loc.path.end_with?("_test.rb") }&.to_s || caller_locations(1, 1).first.to_s

    file_names = Dir.glob("test/files/#{file_type}/*.*").reject { |name| name.end_with?(".md", ".json") }

    missing_file_names = file_names - hashes.keys
    if missing_file_names.any?
      lines = missing_file_names.map { |file_name| "        #{preview_hash_line(file_name)}" }
      flunk("test/files/#{file_type} has untested files; add these lines to the thumbnail test:\n#{lines.join("\n")}\nDefined at: #{call_location}")
    end

    extra_file_names = hashes.keys - file_names
    assert_empty(extra_file_names, "hashes has entries for files that no longer exist: #{extra_file_names}\nDefined at: #{call_location}")

    hashes.each do |file_name, expected|
      preview = generate_preview(file_name)

      if expected.nil?
        assert_nil(preview, "On file: #{file_name}\nDefined at: #{call_location}")
      else
        width, height, hash = expected
        assert_equal([width, height], preview&.dimensions, "On file: #{file_name}\nDefined at: #{call_location}")
        assert_equal(hash, preview&.pixel_hash, "On file: #{file_name}\nDefined at: #{call_location}")
      end
    rescue Minitest::Assertion => e
      raise e.exception("On file: #{file_name}\nDefined at: #{call_location}\n#{e.message}")
    ensure
      preview&.close
    end
  end

  # @return [MediaFile, nil] the 150x150 preview of the file, or nil if generating a preview isn't supported
  #   or fails
  def generate_preview(file_name)
    MediaFile.open(file_name) do |file|
      file.preview(150, 150)
    rescue NotImplementedError
      nil
    end
  end

  # @return [String] a hash literal line (e.g. `"test/files/png/foo.png" => [16, 16, "abc123"],`) suitable for
  #   pasting directly into a `should_generate_previews` call, describing the current preview for the file
  def preview_hash_line(file_name)
    preview = generate_preview(file_name)

    if preview.nil?
      "#{file_name.inspect} => nil,"
    else
      width, height = preview.dimensions
      hash = preview.pixel_hash
      preview.close
      "#{file_name.inspect} => [#{width}, #{height}, #{hash.inspect}],"
    end
  end
end
