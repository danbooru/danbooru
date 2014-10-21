require "test_helper"

class PixivUgoiraConverterTest < ActiveSupport::TestCase
  context "An ugoira converter" do
    setup do
      @zipped_body = "#{Rails.root}/test/fixtures/ugoira.zip"
      @write_file = Tempfile.new("converted")
      @preview_write_file = Tempfile.new("preview")
      @frame_data = [
        {"file" => "000000.jpg", "delay" => 200},
        {"file" => "000001.jpg", "delay" => 200},
        {"file" => "000002.jpg", "delay" => 200},
        {"file" => "000003.jpg", "delay" => 200},
        {"file" => "000004.jpg", "delay" => 250}
      ]
    end

    teardown do
      @write_file.unlink
      @preview_write_file.unlink
    end

    should "output to webm" do
      @converter = PixivUgoiraConverter
      @converter.convert(@zipped_body, @write_file.path, @preview_write_file.path, @frame_data)
      assert_operator(File.size(@write_file.path), :>, 1_000)
      assert_operator(File.size(@preview_write_file.path), :>, 0)
    end
  end
end