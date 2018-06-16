require 'test_helper'

class PostFlagTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      travel_to(2.weeks.ago) do
        @alice = create(:gold_user)
      end
      as(@alice) do
        @post = create(:post, tag_string: "aaa", uploader: @alice)
      end
    end

    context "a basic user" do
      setup do
        travel_to(2.weeks.ago) do
          @bob = create(:user)
        end
      end

      should "not be able to flag more than 1 post in 24 hours" do
        @post_flag = PostFlag.new(post: @post, reason: "aaa", is_resolved: false)
        @post_flag.expects(:flag_count_for_creator).returns(1)
        assert_difference("PostFlag.count", 0) do
          as(@bob) { @post_flag.save }
        end
        assert_equal(["You can flag 1 post a day"], @post_flag.errors.full_messages)
      end
    end

    context "a gold user" do
      setup do
        travel_to(2.weeks.ago) do
          @bob = create(:gold_user)
        end
      end

      should "not be able to flag a post more than twice" do
        assert_difference(-> { PostFlag.count }, 1) do
          as(@bob) do
            @post_flag = PostFlag.create(post: @post, reason: "aaa", is_resolved: false) 
          end
        end

        assert_difference(-> { PostFlag.count }, 0) do
          as(@bob) do
            @post_flag = PostFlag.create(post: @post, reason: "aaa", is_resolved: false)
          end
        end

        assert_equal(["have already flagged this post"], @post_flag.errors[:creator_id])
      end

      should "not be able to target a single uploader" do
        travel_to(2.weeks.ago) do
          as(@alice) do
            @posts = FactoryBot.create_list(:post, 10, uploader: @alice)
          end
        end

        as(@bob) do
          travel_to(1.week.ago) do
            @flags = @posts.map {|x| PostFlag.create(reason: "bad #{x.id}", post: x)}
          end

          @bad_flag = PostFlag.create(post: @post, reason: "bad #{@post.id}")
        end

        assert_equal(["You cannot flag posts uploaded by this user"], @bad_flag.errors.full_messages)
      end

      should "not be able to flag more than 10 posts in 24 hours" do
        as(@bob) do
          @post_flag = PostFlag.new(post: @post, reason: "aaa", is_resolved: false)
          @post_flag.expects(:flag_count_for_creator).returns(10)

          assert_difference(-> { PostFlag.count }, 0) do
            @post_flag.save
          end
        end
        assert_equal(["You can flag 10 posts a day"], @post_flag.errors.full_messages)
      end

      should "not be able to flag a deleted post" do
        as(@alice) do
          @post.update(is_deleted: true)
        end

        assert_difference(-> { PostFlag.count }, 0) do
          as(@bob) do
            @post_flag = PostFlag.create(post: @post, reason: "aaa", is_resolved: false)
          end
        end
        assert_equal(["Post is deleted"], @post_flag.errors.full_messages)
      end

      should "not be able to flag a pending post" do
        as(@alice) do
          @post.update(is_pending: true)
        end
        as(@bob) do
          @flag = @post.flags.create(reason: "test")
        end

        assert_equal(["Post is pending and cannot be flagged"], @flag.errors.full_messages)
      end

      should "not be able to flag a post in the cooldown period" do
        @mod = create(:moderator_user)

        travel_to(2.weeks.ago) do
          @users = FactoryBot.create_list(:user, 2)
        end

        as(@users.first) do
          @flag1 = PostFlag.create(post: @post, reason: "something")
        end

        as(@mod) do
          @post.approve!
        end

        travel_to(PostFlag::COOLDOWN_PERIOD.from_now - 1.minute) do
          as(@users.second) do
            @flag2 = PostFlag.create(post: @post, reason: "something")
          end
          assert_match(/cannot be flagged more than once/, @flag2.errors[:post].join)
        end

        travel_to(PostFlag::COOLDOWN_PERIOD.from_now + 1.minute) do
          as(@users.second) do
            @flag3 = PostFlag.create(post: @post, reason: "something")
          end
          assert(@flag3.errors.empty?)
        end
      end

      should "initialize its creator" do
        @post_flag = as(@alice) do
          PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
        end
        assert_equal(@alice.id, @post_flag.creator_id)
        assert_equal(IPAddr.new("127.0.0.1"), @post_flag.creator_ip_addr)
      end
    end

    context "a moderator user" do
      setup do
        travel_to(2.weeks.ago) do
          @dave = create(:moderator_user)
        end
      end

      should "not be able to view flags on their own uploads" do
        @modpost = create(:post, :tag_string => "mmm", :uploader => @dave)
        as(@alice) do
          @flag1 = PostFlag.create(:post => @modpost, :reason => "aaa", :is_resolved => false)
        end

        assert_equal(false, @dave.can_view_flagger_on_post?(@flag1))

        as(@dave) do
          flag2 = PostFlag.search(:creator_id => @alice.id)
          assert_equal(0, flag2.length)
          flag3 = PostFlag.search({})
          assert_nil(JSON.parse(flag3.to_json)[0]["creator_id"])
        end
      end
    end
  end
end
