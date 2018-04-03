require 'test_helper'

class PostFlagTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      Timecop.travel(2.weeks.ago) do
        @alice = FactoryBot.create(:gold_user)
      end
      CurrentUser.user = @alice
      CurrentUser.ip_addr = "127.0.0.2"
      @post = FactoryBot.create(:post, :tag_string => "aaa")
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "a basic user" do
      setup do
        Timecop.travel(2.weeks.ago) do
          @bob = FactoryBot.create(:user)
        end
        CurrentUser.user = @bob
      end

      should "not be able to flag more than 1 post in 24 hours" do
        @post_flag = PostFlag.new(:post => @post, :reason => "aaa", :is_resolved => false)
        @post_flag.expects(:flag_count_for_creator).returns(1)
        assert_difference("PostFlag.count", 0) do
          @post_flag.save
        end
        assert_equal(["You can flag 1 post a day"], @post_flag.errors.full_messages)
      end
    end

    context "a gold user" do
      should "not be able to flag a post more than twice" do
        assert_difference("PostFlag.count", 1) do
          @post_flag = PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
        end

        assert_difference("PostFlag.count", 0) do
          @post_flag = PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
        end

        assert_equal(["have already flagged this post"], @post_flag.errors[:creator_id])
      end

      should "not be able to flag more than 10 posts in 24 hours" do
        @post_flag = PostFlag.new(:post => @post, :reason => "aaa", :is_resolved => false)
        @post_flag.expects(:flag_count_for_creator).returns(10)
        assert_difference("PostFlag.count", 0) do
          @post_flag.save
        end
        assert_equal(["You can flag 10 posts a day"], @post_flag.errors.full_messages)
      end

      should "not be able to flag a deleted post" do
        @post.update_attribute(:is_deleted, true)
        assert_difference("PostFlag.count", 0) do
          @post_flag = PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
        end
        assert_equal(["Post is deleted"], @post_flag.errors.full_messages)
      end

      should "not be able to flag a pending post" do
        @post.update_columns(is_pending: true)
        @flag = @post.flags.create(reason: "test")

        assert_equal(["Post is pending and cannot be flagged"], @flag.errors.full_messages)
      end

      should "not be able to flag a post in the cooldown period" do
        users = FactoryBot.create_list(:user, 2, created_at: 2.weeks.ago)
        flag1 = FactoryBot.create(:post_flag, post: @post, creator: users.first)
        @post.approve!

        travel_to(PostFlag::COOLDOWN_PERIOD.from_now - 1.minute) do
          flag2 = FactoryBot.build(:post_flag, post: @post, creator: users.second)
          assert(flag2.invalid?)
          assert_match(/cannot be flagged more than once/, flag2.errors[:post].join)
        end

        travel_to(PostFlag::COOLDOWN_PERIOD.from_now + 1.minute) do
          flag3 = FactoryBot.build(:post_flag, post: @post, creator: users.second)
          assert(flag3.valid?)
        end
      end

      should "initialize its creator" do
        @post_flag = PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
        assert_equal(@alice.id, @post_flag.creator_id)
        assert_equal(IPAddr.new("127.0.0.2"), @post_flag.creator_ip_addr)
      end
    end

    context "a moderator user" do
      setup do
        Timecop.travel(2.weeks.ago) do
          @dave = FactoryBot.create(:moderator_user)
        end
        CurrentUser.user = @dave
      end

      should "not be able to view flags on their own uploads" do
        @modpost = FactoryBot.create(:post, :tag_string => "mmm",:uploader_id => @dave.id)
        CurrentUser.scoped(@alice) do
          @flag1 = PostFlag.create(:post => @modpost, :reason => "aaa", :is_resolved => false)
        end
        assert_equal(false, @dave.can_view_flagger_on_post?(@flag1))
        flag2 = PostFlag.search(:creator_id => @alice.id)
        assert_equal(0, flag2.length)
        flag3 = PostFlag.search({})
        assert_nil(JSON.parse(flag3.to_json)[0]["creator_id"])
      end
    end
  end
end
