require "application_system_test_case"

class BlacklistTest < ApplicationSystemTestCase
  context "Blacklists" do
    context "on the /comments page" do
      should "hide the entire post" do
        user = create(:user, created_at: 1.month.ago)
        post = create(:post, tag_string: "spoilers")
        comment = as(user) { create(:comment, post: post) }

        visit comments_path
        assert_selector ".post", visible: :hidden
      end
    end
  end
end
