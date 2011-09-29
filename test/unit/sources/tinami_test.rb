# encoding: UTF-8

require 'test_helper'

module Sources
  class TinamiTest < ActiveSupport::TestCase
    context "The source site for tinami" do
      context "for tinami" do
        setup do
          @site = Sources::Site.new("http://www.tinami.com/view/308311")
          @site.get
        end
        
        should "get a single post" do
          assert_equal("http://www.tinami.com/creator/profile/29399", @site.profile_url)
          assert_match(/ROM/, @site.artist_name)
          assert_equal("http://img.tinami.com/illust2/img/336/4e80b9773c084.png", @site.image_url)
          assert(@site.tags.size > 0)
        end
        
        should "convert a page into a json representation" do
          assert_nothing_raised do
            @site.to_json
          end
        end
      end
    end
  end
end
