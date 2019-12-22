require 'test_helper'

module Downloads
  class FileTest < ActiveSupport::TestCase
    context "A post download" do
      setup do
        ENV["SKIP_CLOUDFLARE_CHECK"] = "1"
        @source = "http://www.google.com/intl/en_ALL/images/logo.gif"
        @download = Downloads::File.new(@source)
      end

      teardown do
        ENV["SKIP_CLOUDFLARE_CHECK"] = nil
      end

      context "for a banned IP" do
        setup do
          Resolv.expects(:getaddress).returns("127.0.0.1").at_least_once
        end

        should "not try to download the file" do
          assert_raise(Downloads::File::Error) { Downloads::File.new("http://evil.com").download! }
        end

        should "not try to fetch the size" do
          assert_raise(Downloads::File::Error) { Downloads::File.new("http://evil.com").size }
        end

        should "not follow redirects to banned IPs" do
          url = "http://httpbin.org/redirect-to?url=http://127.0.0.1"
          stub_request(:get, url).to_return(status: 301, headers: { "Location": "http://127.0.0.1" })

          assert_raise(Downloads::File::Error) { Downloads::File.new(url).download! }
        end

        should "not follow redirects that resolve to a banned IP" do
          url = "http://httpbin.org/redirect-to?url=http://127.0.0.1.nip.io"
          stub_request(:get, url).to_return(status: 301, headers: { "Location": "http://127.0.0.1.xip.io" })

          assert_raise(Downloads::File::Error) { Downloads::File.new(url).download! }
        end
      end

      context "that fails" do
        should "retry three times before giving up" do
          HTTParty.expects(:get).times(3).raises(Errno::ETIMEDOUT)
          assert_raises(Errno::ETIMEDOUT) { @download.download! }
        end

        should "return an uncorrupted file on the second try" do
          bomb = stub("bomb")
          bomb.stubs(:code).raises(IOError)
          resp = stub("resp", success?: true)

          chunk = stub("a")
          chunk.stubs(:code).returns(200)
          chunk.stubs(:size).returns(1)
          chunk.stubs(:to_s).returns("a")

          HTTParty.expects(:get).twice.multiple_yields(chunk, bomb).then.multiple_yields(chunk, chunk).returns(resp)
          @download.stubs(:is_cloudflare?).returns(false)
          tempfile, _strategy = @download.download!

          assert_equal("aa", tempfile.read)
        end
      end

      should "throw an exception when the file is larger than the maximum" do
        assert_raise(Downloads::File::Error) do
          @download.download!(max_size: 1)
        end
      end

      should "store the file in the tempfile path" do
        tempfile, strategy = @download.download!
        assert_operator(tempfile.size, :>, 0, "should have data")
      end

      should "correctly save the file when following 302 redirects" do
        download = Downloads::File.new("https://yande.re/post/show/578014")
        file, strategy = download.download!(url: download.preview_url)
        assert_equal(19134, file.size)
      end
    end
  end
end
