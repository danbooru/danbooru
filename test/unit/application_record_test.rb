require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  setup do
    @tags = create_list(:tag, 3, post_count: 1)
  end

  context "ApplicationRecord#parallel_find_each" do
    context "in threaded mode" do
      should "set CurrentUser correctly" do
        @user1 = create(:user)
        @user2 = create(:user)

        as(@user1) do
          Tag.parallel_find_each do
            assert_equal(@user1, CurrentUser.user)

            as(@user2) do
              assert_equal(@user2, CurrentUser.user)
            end

            assert_equal(@user1, CurrentUser.user)
          end
        end
      end
    end
  end

  context "ApplicationRecord#paginated_search" do
    setup do
      @user = create(:user)
    end

    should "allow up to 1000 results per page by default" do
      assert_equal(1000, as(@user) { Tag.paginated_search(ActionController::Parameters.new, limit: 5000).records_per_page })
    end

    should "allow up to 10000 results per page for sitemaps" do
      assert_equal(10_000, as(@user) { Tag.paginated_search(ActionController::Parameters.new(format: "sitemap"), limit: 50_000).records_per_page })
    end

    should "not allow more than max_limit results per page" do
      assert_equal(2, as(@user) { Tag.paginated_search(ActionController::Parameters.new, limit: 5, max_limit: 2).records_per_page })
      assert_equal(2, as(@user) { Tag.paginated_search(ActionController::Parameters.new, limit: 5, max_limit: 2).size })
    end
  end

  context "ApplicationRecord#destroy_duplicates!" do
    should "destroy all duplicates" do
      @post1 = create(:post, score: 42)
      @post2 = create(:post, score: 42)
      @post3 = create(:post, score: 42)
      @post4 = create(:post, score: 23)

      Post.destroy_duplicates!(:score)

      assert_equal(true,  Post.exists?(@post1.id))
      assert_equal(false, Post.exists?(@post2.id))
      assert_equal(false, Post.exists?(@post3.id))
      assert_equal(true,  Post.exists?(@post4.id))
    end
  end
end
