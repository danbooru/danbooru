require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  context "A comment" do
    setup do
      user = FactoryGirl.create(:user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "created by a limited user" do
      setup do
        Danbooru.config.stubs(:member_comment_limit).returns(5)
        Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.ago)
      end
      
      should "fail creation" do
        comment = FactoryGirl.build(:comment)
        comment.save
        assert_equal(["Creator can not post comments within 1 week of sign up, and can only post 5 comments per hour after that"], comment.errors.full_messages)
      end
    end
    
    context "created by an unlimited user" do
      setup do
        Danbooru.config.stubs(:member_comment_limit).returns(100)
        Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      end
      
      context "that is then deleted" do
        setup do
          @post = FactoryGirl.create(:post)
          @comment = FactoryGirl.create(:comment, :post_id => @post.id)
          @comment.destroy
          @post.reload
        end
        
        should "nullify the last_commented_at field" do
          assert_nil(@post.last_commented_at)
        end
      end

      should "be created" do
        comment = FactoryGirl.build(:comment)
        comment.save
        assert(comment.errors.empty?, comment.errors.full_messages.join(", "))
      end

      should "not bump the parent post" do
        post = FactoryGirl.create(:post)
        comment = FactoryGirl.create(:comment, :do_not_bump_post => "1", :post => post)
        post.reload
        assert_nil(post.last_commented_at)

        comment = FactoryGirl.create(:comment, :post => post)
        post.reload
        assert_not_nil(post.last_commented_at)
      end

      should "not update the post after exceeding the threshold" do
        Danbooru.config.stubs(:comment_threshold).returns(1)
        p = FactoryGirl.create(:post)
        c1 = FactoryGirl.create(:comment, :post => p)
        sleep 1
        c2 = FactoryGirl.create(:comment, :post => p)
        p.reload
        assert_equal(c1.created_at.to_s, p.last_commented_at.to_s)
      end

      should "not allow duplicate votes" do
        user = FactoryGirl.create(:user)
        post = FactoryGirl.create(:post)
        c1 = FactoryGirl.create(:comment, :post => post)
        comment_vote = c1.vote!("up")
        assert_equal([], comment_vote.errors.full_messages)
        comment_vote = c1.vote!("up")
        assert_equal(["You have already voted for this comment"], comment_vote.errors.full_messages)
        assert_equal(1, CommentVote.count)
        assert_equal(1, CommentVote.last.score)

        c2 = FactoryGirl.create(:comment, :post => post)
        comment_vote = c2.vote!("up")
        assert_equal([], comment_vote.errors.full_messages)
        assert_equal(2, CommentVote.count)
      end

      should "be searchable" do
        c1 = FactoryGirl.create(:comment, :body => "aaa bbb ccc")
        c2 = FactoryGirl.create(:comment, :body => "aaa ddd")
        c3 = FactoryGirl.create(:comment, :body => "eee")

        matches = Comment.body_matches("aaa")
        assert_equal(2, matches.count)
        assert_equal(c2.id, matches.all[0].id)
        assert_equal(c1.id, matches.all[1].id)
      end
    end
  end
end
