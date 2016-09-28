require 'test_helper'

module Downloads
  class FileTest < ActiveSupport::TestCase
    def setup
      super
      @record = false
      setup_vcr
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
          Net::HTTP.stubs(:start).raises(Errno::ETIMEDOUT)
        end

        should "retry three times" do
          assert_raises(Errno::ETIMEDOUT) do
            @download.http_get_streaming(@source) {}
          end
        end
      end

      should "stream a file from an HTTP source" do
        VCR.use_cassette("downloads-file-test/http", :record => @vcr_record_option) do
          @download.http_get_streaming(@source) do |resp|
            assert_equal("200", resp.code)
            assert(resp["Content-Length"].to_i > 0, "File should be larger than 0 bytes")
          end
        end
      end

      should "throw an exception when the file is larger than the maximum" do
        assert_raise(Downloads::File::Error) do
          VCR.use_cassette("downloads-file-test/http", :record => @vcr_record_option) do
            @download.http_get_streaming(@source, {}, :max_size => 1) do |resp|
            end
          end
        end
      end

      should "store the file in the tempfile path" do
        VCR.use_cassette("downloads-file-test/http", :record => @vcr_record_option) do
          @download.download!
        end

        assert_equal(@source, @download.source)
        assert(::File.exists?(@tempfile.path), "temp file should exist")
        assert(::File.size(@tempfile.path) > 0, "should have data")
      end

      should "initialize the content type" do
        VCR.use_cassette("downloads-file-test/http", :record => @vcr_record_option) do
          @download.download!
        end

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
        VCR.use_cassette("downloads-file-test/https", :record => @vcr_record_option) do
          @download.http_get_streaming(@source) do |resp|
            assert_equal("200", resp.code)
            assert(resp["Content-Length"].to_i > 0, "File should be larger than 0 bytes")
          end
        end
      end
    end
  end
end
