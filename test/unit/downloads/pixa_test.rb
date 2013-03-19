# require 'test_helper'
#
# module Downloads
#   class PixaTest < ActiveSupport::TestCase
#     context "a download for a pixa image" do
#       setup do
#         @source = "http://file0.pixa.cc/illustrations/6f/d6/3f/f9/51/61/29/72/23/ac/middle/sse.jpg?1317405928"
#         @tempfile = Tempfile.new("danbooru-test")
#         @download = Downloads::File.new(@source, @tempfile.path)
#       end
#
#       should "work" do
#         @download.download!
#         assert_equal(104627, ::File.size(@tempfile.path))
#       end
#     end
#   end
# end
