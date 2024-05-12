require 'test_helper'

module Sources
  class InstagramTest < ActiveSupport::TestCase
    context "Instagram:" do
      should "Parse Instagram URLs correctly" do
        assert(Source::URL.image_url?("https://scontent-lga3-1.cdninstagram.com/v/t51.2885-15/sh0.08/e35/s640x640/202831473_394388808595845_6890631933098833028_n.jpg?_nc_ht=scontent-lga3-1.cdninstagram.com&_nc_cat=109&_nc_ohc=Fcle68OyC80AX8VTGxs&edm=AABBvjUBAAAA&ccb=7-4&oh=00_AT_DYX0zhyNR9vo6ZFKfXjzEWqwFLLfEd3qcpAds5KIvnA&oe=6216DDB5&_nc_sid=83d603"))
        assert(Source::URL.image_url?("https://instagram.fgyn2-1.fna.fbcdn.net/v/t51.2885-15/260126945_125485689990401_3753783352853967169_n.webp?stp=dst-jpg_e35_s750x750_sh0.08&_nc_ht=instagram.fgyn2-1.fna.fbcdn.net&_nc_cat=105&_nc_ohc=7njl7WM7D1cAX_oe4xv&tn=ZvUMUWKqovKgvpX-&edm=AABBvjUBAAAA&ccb=7-4&ig_cache_key=Mjc2NTM3ODUzMDE2MTA4OTMyNw==.2-ccb7-4&oh=00_AT9T3WAiFaHEf1labFFZiXHjy-8nacOA13AWl6hDEPz_EQ&oe=6230B686&_nc_sid=83d603"))

        assert(Source::URL.page_url?("https://www.instagram.com/p/CbDW9mVuEnn/"))
        assert(Source::URL.page_url?("https://www.instagram.com/reel/CV7mHEwgbeF/?utm_medium=copy_link"))
        assert(Source::URL.page_url?("https://www.instagram.com/tv/CMjUD1epVWW/"))
        assert(Source::URL.page_url?("https://www.instagram.com/peachmomoko60/p/CyyRYaBxp25/"))
        assert(Source::URL.page_url?("https://instagr.am/p/CJVuiRZjrB9/"))

        assert(Source::URL.profile_url?("https://www.instagram.com/itomugi/"))
        assert(Source::URL.profile_url?("https://www.instagram.com/stories/itomugi/"))
        assert(Source::URL.profile_url?("https://instagr.am/Zurasuta"))
      end
    end
  end
end
