require "application_system_test_case"

module PostTooltipTests
  extend ActiveSupport::Concern

  included do
    context "#{browser_name}:" do
      context "Post tooltips" do
        setup do
          @post = create(:post, file_ext: "swf")
        end

        context "on a post thumbnail" do
          should "show the tooltip when hovering over the thumbnail" do
            visit posts_path

            find(".post-preview img").hover
            assert_selector ".post-tooltip-body"
          end
        end

        context "on a post #xxx link" do
          should "show the tooltip when hovering over the link" do
            user = create(:user, created_at: 1.month.ago)
            comment = as(user) { create(:comment, post: @post, body: "post ##{@post.id}") }

            visit comment_path(comment)
            find(".dtext-post-id-link").hover
            assert_selector ".post-tooltip-body"
          end
        end
      end
    end
  end
end

class PostTooltipChromeTest < ChromeSystemTestCase
  include PostTooltipTests
end

class PostTooltipFirefoxTest < FirefoxSystemTestCase
  include PostTooltipTests
end

class PostTooltipWebkitTest < WebkitSystemTestCase
  include PostTooltipTests
end
