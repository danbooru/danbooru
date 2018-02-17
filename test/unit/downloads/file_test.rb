require 'test_helper'

module Downloads
  class FileTest < ActiveSupport::TestCase
    context "A twitter video download" do
      setup do
        @source = "https://twitter.com/CincinnatiZoo/status/859073537713328129"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
      end

      teardown do
        @tempfile.close
      end

      should "preserve the twitter source" do
        @download.download!
        assert_equal("https://twitter.com/CincinnatiZoo/status/859073537713328129", @download.source)
      end
    end

    context "A post download" do
      setup do
        @source = "http://www.google.com/intl/en_ALL/images/logo.gif"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
      end

      teardown do
        @tempfile.close
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
        @download.download!
        assert_equal(@source, @download.source)
        assert(::File.exists?(@tempfile.path), "temp file should exist")
        assert(::File.size(@tempfile.path) > 0, "should have data")
      end
    end
  end
end
