require "application_system_test_case"

module BlacklistTests
  extend ActiveSupport::Concern

  # Click the "..." button on the blacklist box, then click one of the options in the popup menu
  # (e.g. "Autoclose", "Show all", "Blur images").
  def toggle_blacklist_option(label)
    find("#blacklist-box .popup-menu-button").click
    find("#blacklist-box label", text: label).click
  end

  # Click the "Blacklisted" checkbox that enables or disables the entire blacklist.
  def toggle_blacklist_enabled
    find("#blacklist-box label", text: "Blacklisted").click
  end

  def assert_post_hidden(post)
    selector = post_selector(post)
    assert_hidden "#{selector}.blacklisted-hidden"
  end

  def assert_post_blurred(post)
    selector = post_selector(post)
    assert_visible "#{selector}.blacklisted-blurred"
    assert_no_selector "#{selector}.blacklisted-hidden"
  end

  def assert_post_not_blacklisted(post)
    selector = post_selector(post)
    assert_visible selector
    assert_no_selector "#{selector}.blacklisted-active"
  end

  included do
    context "#{browser_name}:" do
      context "Blacklists:" do
        setup do
          @user = create(:user, blacklisted_tags: "1girl\n2girls", created_at: 1.month.ago)
          @blacklisted_post = create(:post, tag_string: "1girl")
          @safe_post = create(:post, tag_string: "safe")

          signin @user
        end

        context "on the /posts page" do
          setup do
            visit posts_path
          end

          should "hide blacklisted posts and show non-blacklisted posts" do
            assert_post_hidden @blacklisted_post
            assert_post_not_blacklisted @safe_post
          end

          context "blacklist.blurimages" do
            should "blur blacklisted posts instead of hiding them when enabled" do
              toggle_blacklist_option("Blur images")

              assert_post_blurred @blacklisted_post
            end
          end

          context "blacklist.showall" do
            should "only show rules matching posts by default, and all rules when enabled" do
              toggle_blacklist_enabled

              assert_visible "#blacklist-box a", text: "1girl"
              assert_no_selector "#blacklist-box a", text: "2girls"

              toggle_blacklist_option("Show all")

              assert_visible "#blacklist-box a", text: "1girl"
              assert_visible "#blacklist-box a", text: "2girls"
            end
          end

          context "blacklist.autocollapse" do
            should "automatically collapse the blacklist box when toggling the blacklist, by default" do
              assert_hidden "#blacklist-box a", text: "1girl"

              toggle_blacklist_enabled
              assert_visible "#blacklist-box a", text: "1girl"

              toggle_blacklist_enabled
              assert_hidden "#blacklist-box a", text: "1girl"
            end

            should "not collapse the blacklist box when toggling the blacklist, when disabled" do
              toggle_blacklist_option("Autoclose")
              assert_hidden "#blacklist-box a", text: "1girl"

              toggle_blacklist_enabled
              assert_hidden "#blacklist-box a", text: "1girl"

              toggle_blacklist_enabled
              assert_hidden "#blacklist-box a", text: "1girl"
            end
          end
        end

        context "on the /comments page" do
          setup do
            as(@user) { create(:comment, post: @blacklisted_post) }
            as(@user) { create(:comment, post: @safe_post) }

            visit comments_path
          end

          should "hide blacklisted posts and show non-blacklisted posts" do
            assert_post_hidden @blacklisted_post
            assert_post_not_blacklisted @safe_post
          end
        end

        context "on the /comments page, grouped by comment" do
          setup do
            as(@user) { create(:comment, post: @blacklisted_post) }
            as(@user) { create(:comment, post: @safe_post) }

            visit comments_path(group_by: "comment")
          end

          should "hide blacklisted posts and show non-blacklisted posts" do
            assert_post_hidden @blacklisted_post
            assert_post_not_blacklisted @safe_post
          end
        end

        context "on the /favorites page" do
          setup do
            create(:favorite, user: @user, post: @blacklisted_post)
            create(:favorite, user: @user, post: @safe_post)

            visit favorites_path
          end

          should "hide blacklisted posts and show non-blacklisted posts" do
            assert_post_hidden @blacklisted_post
            assert_post_not_blacklisted @safe_post
          end
        end

        context "on the /post_votes page" do
          setup do
            create(:post_vote, user: @user, post: @blacklisted_post)
            create(:post_vote, user: @user, post: @safe_post)

            visit post_votes_path
          end

          should "hide blacklisted posts and show non-blacklisted posts" do
            assert_post_hidden @blacklisted_post
            assert_post_not_blacklisted @safe_post
          end
        end

        context "on the /comment_votes page" do
          setup do
            blacklisted_comment = as(@user) { create(:comment, post: @blacklisted_post) }
            safe_comment = as(@user) { create(:comment, post: @safe_post) }

            create(:comment_vote, user: @user, comment: blacklisted_comment)
            create(:comment_vote, user: @user, comment: safe_comment)

            visit comment_votes_path
          end

          should "hide blacklisted posts and show non-blacklisted posts" do
            assert_post_hidden @blacklisted_post
            assert_post_not_blacklisted @safe_post
          end
        end

        context "on the /artist_commentaries page" do
          setup do
            create(:artist_commentary, post: @blacklisted_post)
            create(:artist_commentary, post: @safe_post)

            visit artist_commentaries_path
          end

          should "hide blacklisted posts and show non-blacklisted posts" do
            assert_post_hidden @blacklisted_post
            assert_post_not_blacklisted @safe_post
          end
        end

        context "on the /post/ID page" do
          should "hide blacklisted posts and show non-blacklisted posts" do
            visit post_path(@blacklisted_post)
            assert_hidden ".image-container.blacklisted-hidden"

            visit post_path(@safe_post)
            assert_visible ".image-container"
            assert_no_selector ".image-container.blacklisted-active"
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
