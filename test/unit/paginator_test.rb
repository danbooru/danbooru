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
  end
end
