require "application_system_test_case"

module PostVersionSystemTests
  extend ActiveSupport::Concern

  included do
    context "#{browser_name}:" do
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
          visit post_versions_path(search: { post_id: @post.id })
        end

        context "clicking the undo selected button" do
          should "undo all selected post versions" do
            check id: "post-version-select-all-checkbox"
            undoable_count = all("td .post-version-select-checkbox:not(:disabled)").size
            assert all("td .post-version-select-checkbox:not(:disabled)").all?(&:checked?)

            click_link "subnav-undo-selected"
            assert_notice "#{undoable_count}/#{undoable_count} changes undone."

            assert_equal("tagme", @post.reload.tag_string)
          end
        end
      end
    end
  end
end

class PostVersionSystemChromeTest < ChromeSystemTestCase
  include PostVersionSystemTests
end

class PostVersionSystemFirefoxTest < FirefoxSystemTestCase
  include PostVersionSystemTests
end

class PostVersionSystemWebkitTest < WebkitSystemTestCase
  include PostVersionSystemTests
end
