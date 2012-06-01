# # encoding: UTF-8
# 
# require 'test_helper'
# 
# module Sources
#   class PixaTest < ActiveSupport::TestCase
#     context "The source site for pixa" do
#       setup do
#         @site = Sources::Site.new("http://www.pixa.cc/illustrations/show/75575")
#         @site.get
#       end
#       
#       should "get the profile" do
#         assert_equal("http://www.pixa.cc/profiles/show/9191", @site.profile_url)
#       end
#       
#       should "get the artist name" do
#         assert_equal("air", @site.artist_name)
#       end
#       
#       should "get the image url" do
#         assert_equal("http://file0.pixa.cc/illustrations/34/cb/df/70/49/b4/52/2d/42/c6/middle/110910魔法少女のコピー.jpg?1315664621", @site.image_url)
#       end
#       
#       should "get the tags" do
#         assert(@site.tags.size > 0)
#         first_tag = @site.tags.first
#         assert_equal(2, first_tag.size)
#         assert(first_tag[0] =~ /./)
#       end
# 
#       should "convert a page into a json representation" do
#         assert_nothing_raised do
#           @site.to_json
#         end
#       end
#     end
#   end
# end
