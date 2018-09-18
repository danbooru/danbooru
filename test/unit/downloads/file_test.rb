require 'test_helper'

module Downloads
  class FileTest < ActiveSupport::TestCase
    context "A post download" do
      setup do
        @source = "http://www.google.com/intl/en_ALL/images/logo.gif"
        @download = Downloads::File.new(@source)
        @tempfile = Tempfile.new("danbooru-test")
      end

      context "that fails" do
        setup do
          HTTParty.stubs(:get).raises(Errno::ETIMEDOUT)
        end

        should "retry three times" do
          assert_raises(Errno::ETIMEDOUT) do
            @download.http_get_streaming(@source, @tempfile)
          end
        end
      end

      should "throw an exception when the file is larger than the maximum" do
        assert_raise(Downloads::File::Error) do
          @download.http_get_streaming(@source, @tempfile, {}, max_size: 1)
        end
      end

      should "store the file in the tempfile path" do
        tempfile, strategy = @download.download!
        assert_equal(@source, @download.source)
        assert_operator(tempfile.size, :>, 0, "should have data")
      end
    end
  end
end
