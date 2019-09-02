require "test_helper"

class PixivUgoiraConverterTest < ActiveSupport::TestCase
  context "An ugoira converter" do
    setup do
      @zipfile = upload_file("test/fixtures/ugoira.zip").tempfile
      @frame_data = [
        {"file" => "000000.jpg", "delay" => 200},
        {"file" => "000001.jpg", "delay" => 200},
        {"file" => "000002.jpg", "delay" => 200},
        {"file" => "000003.jpg", "delay" => 200},
        {"file" => "000004.jpg", "delay" => 250}
      ]
    end

    should "output to webm" do
      skip "ffmpeg is not installed" unless PixivUgoiraConverter.enabled?
      sample_file = PixivUgoiraConverter.generate_webm(@zipfile, @frame_data)
      preview_file = PixivUgoiraConverter.generate_preview(@zipfile)
      assert_operator(sample_file.size, :>, 1_000)
      assert_operator(preview_file.size, :>, 0)
    end
  end
end
