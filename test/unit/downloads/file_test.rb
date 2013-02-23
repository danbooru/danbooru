require 'test_helper'

module Downloads
  class FileTest < ActiveSupport::TestCase
    context "A post download" do
      setup do
        @source = "http://www.google.com/intl/en_ALL/images/logo.gif"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
      end
    
      teardown do
        @tempfile.close
      end
    
      should "stream a file from an HTTP source" do
        @download.http_get_streaming do |resp|
          assert_equal("200", resp.code)
          assert(resp["Content-Length"].to_i > 0, "File should be larger than 0 bytes")
        end
      end
    
      should "throw an exception when the file is larger than the maximum" do
        assert_raise(Downloads::File::Error) do
          @download.http_get_streaming(:max_size => 1) do |resp|
          end
        end
      end
    
      should "store the file in the tempfile path" do
        @download.download!
        assert_equal(@source, @download.source)
        assert(::File.exists?(@tempfile.path), "temp file should exist")
        assert(::File.size(@tempfile.path) > 0, "should have data")
      end
    
      should "initialize the content type" do
        @download.download!
        assert_match(/image\/gif/, @download.content_type)
      end
    end

    context "A post download with an HTTPS source" do
      setup do
        @source = "https://www.google.com/intl/en_ALL/images/logo.gif"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
      end

      teardown do
        @tempfile.close
      end

      should "stream a file from an HTTPS source" do
        @download.http_get_streaming do |resp|
          assert_equal("200", resp.code)
          assert(resp["Content-Length"].to_i > 0, "File should be larger than 0 bytes")
        end
      end
    end
  end
end
