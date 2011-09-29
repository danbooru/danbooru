# encoding: UTF-8

require 'test_helper'

module Sources
  class PixaTest < ActiveSupport::TestCase
    context "The source site for nico seiga" do
      setup do
        @site = Sources::Site.new("http://www.pixa.cc/illustrations/show/75575")
        @site.get
      end
      
      should "get a single post" do
        assert_equal("http://www.pixa.cc/profiles/show/9191", @site.profile_url)
        assert(@site.tags.size > 0)
        first_tag = @site.tags.first
        assert_equal(2, first_tag.size)
        assert(first_tag[0] =~ /./)
      end

      should "convert a page into a json representation" do
        assert_nothing_raised do
          @site.to_json
        end
      end
    end
  end
end
