require "application_system_test_case"

module BlacklistTests
  extend ActiveSupport::Concern

  included do
    context "#{browser_name}:" do
      context "Blacklists" do
        context "on the /comments page" do
          should "hide the entire post" do
            user = create(:user, created_at: 1.month.ago)
            post = create(:post, tag_string: "guro")
            as(user) { create(:comment, post: post) }

            visit comments_path
            assert_selector ".post", visible: :hidden
          end
        end
      end
    end
  end
end

class BlacklistChromeTest < ChromeSystemTestCase
  include BlacklistTests
end

class BlacklistFirefoxTest < FirefoxSystemTestCase
  include BlacklistTests
end

class BlacklistWebkitTest < WebkitSystemTestCase
  include BlacklistTests
end
