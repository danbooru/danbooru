require "application_system_test_case"

class PostChromeTest < ChromeSystemTestCase
  setup do
    @user = create(:user, created_at: 1.month.ago)
    @post = create(:post, tag_string: "1girl solo", source: "https://example.com/image.jpg")
  end

  context "Post:" do
    should "show the editing interface" do
      fast_signin @user
      visit post_path(@post)
      find("#post-edit-link").click

      assert_visible "#edit"

      tags = find_field("post_tag_string").value.split
      assert_includes tags, "1girl"
      assert_includes tags, "solo"

      assert_field "post_source", with: "https://example.com/image.jpg"
    end

    should "show the flag modal" do
      fast_signin @user
      visit post_path(@post)

      click_link "Flag"
      assert_selector ".ui-dialog .ui-dialog-title", text: "Flag post"
      assert_selector ".ui-dialog", text: "Submit"
      assert_selector ".ui-dialog", text: "Cancel"
    end

    should "show the appeal modal" do
      fast_signin @user

      @post = create(:post, is_deleted: true)
      visit post_path(@post)
      click_link "Appeal"
      assert_selector ".ui-dialog .ui-dialog-title", text: "Appeal post"
      assert_selector ".ui-dialog", text: "Submit"
      assert_selector ".ui-dialog", text: "Cancel"
    end

    should "show the delete modal" do
      fast_signin create(:approver_user)
      visit post_path(@post)
      click_link "Delete"

      assert_selector ".ui-dialog .ui-dialog-title", text: "Delete Post"
      assert_selector ".ui-dialog", text: "Submit"
      assert_selector ".ui-dialog", text: "Cancel"
    end

    should "show the artist commentary modal with the commentary buttons" do
      fast_signin @user
      visit post_path(@post)

      click_link "Add commentary"
      assert_selector ".ui-dialog .ui-dialog-title", text: "Add artist commentary"

      within(".ui-dialog") do
        assert_button "Fetch"
        assert_button "Submit"
        assert_button "Cancel"
      end
    end
  end
end
