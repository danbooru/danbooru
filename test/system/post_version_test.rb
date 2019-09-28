require "application_system_test_case"

class PostVersionTest < ApplicationSystemTestCase
  context "Post versions" do
    setup do
      @user = create(:builder_user)

      as @user do
        @post = create(:post, tag_string: "tagme")
        travel 2.hours
        @post.update!(tag_string: "touhou")
        travel 2.hours
        @post.update!(tag_string: "touhou bkub")
        travel 2.hours
      end

      signin @user
      visit post_versions_path
    end

    context "clicking the undo selected button" do
      should "undo all selected post versions" do
        check id: "post-version-select-all-checkbox"
        assert all("td .post-version-select-checkbox:not(:disabled)").all?(&:checked?)

        click_link "subnav-undo-selected-link"
        assert_selector "#notice span.prose", text: "2/2 changes undone."

        assert_equal("tagme", @post.reload.tag_string)
      end
    end
  end
end
