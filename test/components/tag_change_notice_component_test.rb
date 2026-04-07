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

    should "escape forum topic titles in pending bulk update notices" do
      user = create(:user)
      tag = create(:tag, name: "aaa")
      topic = create(:forum_topic, title: %{<img src=x onerror="alert(1)">})
      create(:bulk_update_request, user: user, script: "create alias aaa -> bbb", forum_topic: topic)
      create(:bulk_update_request, user: user, script: "create alias aaa -> ccc", forum_topic: topic)

      html = render_inline(TagChangeNoticeComponent.new(tag: tag, current_user: user)).to_html

      assert_no_css("img")
      assert_match(/&lt;img src=x onerror="alert\(1\)"&gt;/, html)
      assert_no_match(/<img src=x onerror="alert\(1\)">/, html)
    end
  end
end
