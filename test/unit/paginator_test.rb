require 'test_helper'

class PaginatorTest < ActiveSupport::TestCase
  setup do
    @posts = FactoryBot.create_list(:post, 5)
  end

  context "sequential pagination (before)" do
    should "return the correct set of records" do
      expected_posts = Post.limit(3).order(id: :desc)
      posts = Post.paginate("b9999999", limit: 3)

      assert_equal(expected_posts.map(&:id), posts.map(&:id))
    end

    should "return nothing for b0" do
      posts = Post.paginate("b0")
      assert_empty(posts.map(&:id))
    end
  end

  context "sequential pagination (after)" do
    should "return the correct set of records" do
      expected_posts = Post.limit(3).order(id: :asc).reverse
      posts = Post.paginate("a0", limit: 3)

      assert_equal(expected_posts.map(&:id), posts.map(&:id))
    end
  end

  context "numbered pagination" do
    should "return the correct set of records" do
      expected_posts = Post.limit(3).order(id: :desc)
      posts = Post.order(id: :desc).paginate("1", limit: 3)

      assert_equal(expected_posts.map(&:id), posts.map(&:id))
    end

    should "raise an error when exceeding the page limit" do
      Danbooru.config.stubs(:max_numbered_pages).returns(5)
      assert_raises(PaginationExtension::PaginationError) do
        Post.paginate(10)
      end
    end

    should "count pages correctly" do
      assert_equal(5, Post.paginate(1, limit: 1).total_pages)
      assert_equal(3, Post.paginate(1, limit: 2).total_pages)
      assert_equal(2, Post.paginate(1, limit: 3).total_pages)
      assert_equal(2, Post.paginate(1, limit: 4).total_pages)
      assert_equal(1, Post.paginate(1, limit: 5).total_pages)
    end

    should "detect the first and last page correctly" do
      assert(Post.paginate(0, limit: 1).is_first_page?)
      assert(Post.paginate(1, limit: 1).is_first_page?)
      refute(Post.paginate(1, limit: 1).is_last_page?)

      refute(Post.paginate(5, limit: 1).is_first_page?)
      assert(Post.paginate(5, limit: 1).is_last_page?)
      assert(Post.paginate(6, limit: 1).is_last_page?)
    end
  end
end
