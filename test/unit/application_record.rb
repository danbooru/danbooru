require 'test_helper'

class ApplicationRecordTest < ActiveSupport::TestCase
  setup do
    @tags = FactoryBot.create_list(:tag, 3, post_count: 1)
  end

  context "ApplicationRecord#search" do
    should "support the id param" do
      assert_equal([@tags.first], Tag.search(id: @tags.first.id))
    end

    should "support ranges in the id param" do
      assert_equal(@tags.reverse, Tag.search(id: ">=1"))
      assert_equal(@tags.reverse, Tag.search(id: "#{@tags[0].id}..#{@tags[2].id}"))
      assert_equal(@tags.reverse, Tag.search(id: @tags.map(&:id).join(",")))
    end

    should "support the created_at and updated_at params" do
      assert_equal(@tags.reverse, Tag.search(created_at: ">=#{@tags.first.created_at}"))
      assert_equal(@tags.reverse, Tag.search(updated_at: ">=#{@tags.first.updated_at}"))
    end
  end

  context "ApplicationRecord#parallel_each" do
    context "in threaded mode" do
      should "set CurrentUser correctly" do
        @user1 = create(:user)
        @user2 = create(:user)

        CurrentUser.scoped(@user1, "1.1.1.1") do
          Tag.parallel_each do |tag|
            assert_equal(@user1, CurrentUser.user)
            assert_equal("1.1.1.1", CurrentUser.ip_addr)

            CurrentUser.scoped(@user2, "2.2.2.2") do
              assert_equal(@user2, CurrentUser.user)
              assert_equal("2.2.2.2", CurrentUser.ip_addr)
            end

            assert_equal(@user1, CurrentUser.user)
            assert_equal("1.1.1.1", CurrentUser.ip_addr)
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
