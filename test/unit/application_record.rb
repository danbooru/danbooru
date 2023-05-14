require 'test_helper'

class ApplicationRecordTest < ActiveSupport::TestCase
  setup do
    @tags = FactoryBot.create_list(:tag, 3, post_count: 1)
  end

  context "ApplicationRecord#parallel_find_each" do
    context "in threaded mode" do
      should "set CurrentUser correctly" do
        @user1 = create(:user)
        @user2 = create(:user)

        CurrentUser.scoped(@user1) do
          Tag.parallel_find_each do |tag|
            assert_equal(@user1, CurrentUser.user)

            CurrentUser.scoped(@user2) do
              assert_equal(@user2, CurrentUser.user)
            end

            assert_equal(@user1, CurrentUser.user)
          end
        end
      end
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
