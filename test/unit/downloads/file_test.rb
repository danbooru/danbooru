require 'test_helper'

module Downloads
  class FileTest < ActiveSupport::TestCase
    context "A post download" do
      setup do
        @source = "http://www.google.com/intl/en_ALL/images/logo.gif"
        @download = Downloads::File.new(@source)
      end

      context "that fails" do
        should "retry three times before giving up" do
          HTTParty.expects(:get).times(3).raises(Errno::ETIMEDOUT)
          assert_raises(Errno::ETIMEDOUT) { @download.download! }
        end

        should "return an uncorrupted file on the second try" do
          bomb = stub("bomb")
          bomb.expects(:size).raises(IOError)
          resp = stub("resp", success?: true)

          HTTParty.expects(:get).twice.multiple_yields("a", bomb, "b", "c").then.multiple_yields("a", "b", "c").returns(resp)
          tempfile, _ = @download.download!

          assert_equal("abc", tempfile.read)
        end
      end

      should "throw an exception when the file is larger than the maximum" do
        assert_raise(Downloads::File::Error) do
          @download.download!(max_size: 1)
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
