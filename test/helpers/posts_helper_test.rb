require "test_helper"

class PostsHelperTest < ActionView::TestCase
  context "The posts helper" do
    context "first_danbirthday method" do
      should "return the creation date of post #1" do
        travel_to(2.days.ago) do
          create(:post, id: 1)
        end

        assert_equal Post.find(1).created_at, first_danbirthday
      end

      should "return nil if post #1 doesn't exist" do
        assert_nil first_danbirthday
      end
    end

    context "is_danbirthday? method" do
      should "be true for post #1 on the anniversary of its creation" do
        travel_to(1.year.ago) do
          @post = create(:post, id: 1)
        end

        assert is_danbirthday?(@post)
      end

      should "be false for post #1 on the day it was created" do
        @post = create(:post, id: 1)

        assert_not is_danbirthday?(@post)
      end

      should "be false for any other post, even on the anniversary of post #1's creation" do
        travel_to(1.year.ago) { create(:post, id: 1) }
        @post = create(:post, id: 2)

        assert_not is_danbirthday?(@post)
      end
    end
  end
end
