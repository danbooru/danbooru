module MediaFileTestHelper
  # Test preview generation: those we expect to generate should be generated, those we expect to fail should fail.
  # This, along with the rest of our media file tests, will alert us in case of library updates that fix our broken cases.
  def should_generate_previews(file_type, failures: [])
    call_location = caller_locations.find { |loc| loc.path.end_with?("_test.rb") }&.to_s || caller_locations(1, 1).first.to_s

    Dir.glob("test/files/#{file_type}/*.*").each do |file_name|
      next if file_name.end_with?(".md", ".json")

      begin
        file = MediaFile.open(file_name)

        begin
          preview = file.preview(150, 150)
        rescue NotImplementedError => e
          assert_includes failures, file_name, "#{file_name} was not expected to fail preview generation"
          return
        end

        if failures.include? file_name
          assert_nil preview&.file_ext
        else
          assert_equal :jpg, preview&.file_ext
          assert_includes 1..file.height, preview.height
          assert_includes 1..file.width, preview.width
        end
      rescue Minitest::Assertion => e
        raise e.exception("On file: #{file_name}\nDefined at: #{call_location}\n#{e.message}")
      rescue Exception => e # rubocop:disable Lint/RescueException
        raise e.exception("On file: #{file_name}\nDefined at: #{call_location}\n#{e.message}")
      end
    end
  end
end
