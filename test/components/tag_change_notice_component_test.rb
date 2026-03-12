require "test_helper"

class TagChangeNoticeComponentTest < ViewComponent::TestCase
  context "The TagChangeNoticeComponent" do
    should "render pending bulk update request notices" do
      user = create(:user)
      tag = create(:tag, name: "aaa")
      create(:bulk_update_request, user: user, script: "create alias aaa -> bbb")

      as(user) do
        render_inline(TagChangeNoticeComponent.new(tag: tag, current_user: user))
      end

      assert_css(".tag-change-notice")
      assert_text("This tag is being discussed")
    end
  end
end
