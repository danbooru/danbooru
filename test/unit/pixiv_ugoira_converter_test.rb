require "test_helper"

class PixivUgoiraConverterTest < ActiveSupport::TestCase
  context "An ugoira converter" do
    setup do
      @url = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46378654"
      @write_file = Tempfile.new("output")
    end

    teardown do
      @write_file.unlink
    end

    should "output to gif" do
      @converter = PixivUgoiraConverter.new(@url, @write_file.path, :gif)
      VCR.use_cassette("ugoira-converter", :record => :new_episodes) do
        @converter.process!
      end
      assert_operator(File.size(@converter.write_path), :>, 1_000)
    end

    should "output to webm" do
      @converter = PixivUgoiraConverter.new(@url, @write_file.path, :webm)
      VCR.use_cassette("ugoira-converter", :record => :new_episodes) do
        @converter.process!
      end
      assert_operator(File.size(@converter.write_path), :>, 1_000)
    end

    # should "output to apng" do
    #   @converter = PixivUgoiraConverter.new(@url, @write_file.path, :apng)
    #   VCR.use_cassette("ugoira-converter", :record => :new_episodes) do
    #     @converter.process!
    #   end
    #   assert_operator(File.size(@converter.write_path), :>, 1_000)
    # end
  end
end