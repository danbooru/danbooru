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

    should "not show pending bulk update requests in private forum topics" do
      user = create(:user)
      mod = create(:moderator_user)
      tag = create(:tag, name: "private_tag")
      private_topic = create(:mod_up_forum_topic, title: "Secret mod discussion")
      as(mod) { create(:bulk_update_request, user: mod, script: "create alias private_tag -> bbb", forum_topic: private_topic) }

      [user, mod].each do |viewer|
        as(viewer) do
          render_inline(TagChangeNoticeComponent.new(tag: tag, current_user: viewer))
        end

        assert_no_css(".tag-change-notice")
        assert_no_text("Secret mod discussion")
      end
    end

    should "not show pending bulk update requests in deleted forum topics" do
      user = create(:user)
      mod = create(:moderator_user)
      tag = create(:tag, name: "deleted_tag")
      topic = create(:forum_topic, title: "Deleted discussion")
      as(mod) { create(:bulk_update_request, user: mod, script: "create alias deleted_tag -> bbb", forum_topic: topic) }
      topic.soft_delete!(updater: mod)

      as(user) do
        render_inline(TagChangeNoticeComponent.new(tag: tag, current_user: user))
      end

      assert_no_css(".tag-change-notice")
      assert_no_text("Deleted discussion")
    end

    should "not raise an error when a pending bulk update request has no forum topic" do
      user = create(:user)
      tag = create(:tag, name: "orphan_tag")
      bur = create(:bulk_update_request, user: user, script: "create alias orphan_tag -> bbb")
      bur.update!(forum_topic: nil, forum_post: nil)

      as(user) do
        render_inline(TagChangeNoticeComponent.new(tag: tag, current_user: user))
      end

      assert_no_css(".tag-change-notice")
    end
  end
end
