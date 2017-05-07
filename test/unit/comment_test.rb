require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  context "A comment" do
    setup do
      user = FactoryGirl.create(:user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "that mentions a user" do
      setup do
        @post = FactoryGirl.create(:post)
        Danbooru.config.stubs(:member_comment_limit).returns(100)
        Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      end

      context "in a quote block" do
        setup do
          @user2 = FactoryGirl.create(:user, :created_at => 2.weeks.ago)
        end

        should "not create a dmail" do
          assert_difference("Dmail.count", 0) do
            FactoryGirl.create(:comment, :post_id => @post.id, :body => "[quote]@#{@user2.name}[/quote]")
          end

          assert_difference("Dmail.count", 0) do
            FactoryGirl.create(:comment, :post_id => @post.id, :body => "[quote]@#{@user2.name}[/quote] blah [quote]@#{@user2.name}[/quote]")
          end

          assert_difference("Dmail.count", 0) do
            FactoryGirl.create(:comment, :post_id => @post.id, :body => "[quote][quote]@#{@user2.name}[/quote][/quote]")
          end

          assert_difference("Dmail.count", 1) do
            FactoryGirl.create(:comment, :post_id => @post.id, :body => "[quote]@#{@user2.name}[/quote] @#{@user2.name}")
          end
        end
      end

      context "outside a quote block" do
        setup do
          @user2 = FactoryGirl.create(:user)
          @comment = FactoryGirl.build(:comment, :post_id => @post.id, :body => "Hey @#{@user2.name} check this out!")
        end

        should "create a dmail" do
          assert_difference("Dmail.count", 1) do
            @comment.save
          end

          dmail = Dmail.last
          assert_equal(<<-EOS.strip_heredoc, dmail.body)
            @#{CurrentUser.name} mentioned you in a \"comment\":/posts/#{@comment.post_id}#comment-#{@comment.id} on post ##{@comment.post_id}:

            [quote]
            Hey @#{@user2.name} check this out!
            [/quote]
          EOS
        end
      end
    end

    context "created by a limited user" do
      setup do
        Danbooru.config.stubs(:member_comment_limit).returns(5)
        Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.ago)
      end

      should "fail creation" do
        comment = FactoryGirl.build(:comment)
        comment.save
        assert_equal(["You can not post comments within 1 week of sign up"], comment.errors.full_messages)
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
          @comment.update({is_deleted: true}, as: :member)
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

      should "not validate if the post does not exist" do
        comment = FactoryGirl.build(:comment, :post_id => -1)

        assert_not(comment.valid?)
        assert_equal(["must exist"], comment.errors[:post])
      end

      should "not bump the parent post" do
        post = FactoryGirl.create(:post)
        comment = FactoryGirl.create(:comment, :do_not_bump_post => true, :post => post)
        post.reload
        assert_nil(post.last_comment_bumped_at)

        comment = FactoryGirl.create(:comment, :post => post)
        post.reload
        assert_not_nil(post.last_comment_bumped_at)
      end

      should "not bump the post after exceeding the threshold" do
        Danbooru.config.stubs(:comment_threshold).returns(1)
        p = FactoryGirl.create(:post)
        c1 = FactoryGirl.create(:comment, :post => p)
        Timecop.travel(2.seconds.from_now) do
          c2 = FactoryGirl.create(:comment, :post => p)
        end
        p.reload
        assert_equal(c1.created_at.to_s, p.last_comment_bumped_at.to_s)
      end

      should "always record the last_commented_at properly" do
        post = FactoryGirl.create(:post)
        Danbooru.config.stubs(:comment_threshold).returns(1)

        c1 = FactoryGirl.create(:comment, :do_not_bump_post => true, :post => post)
        post.reload
        assert_equal(c1.created_at.to_s, post.last_commented_at.to_s)

        Timecop.travel(2.seconds.from_now) do
          c2 = FactoryGirl.create(:comment, :post => post)
          post.reload
          assert_equal(c2.created_at.to_s, post.last_commented_at.to_s)
        end
      end

      should "not record the user id of the voter" do
        user = FactoryGirl.create(:user)
        post = FactoryGirl.create(:post)
        c1 = FactoryGirl.create(:comment, :post => post)
        CurrentUser.scoped(user, "127.0.0.1") do
          c1.vote!("up")
          c1.reload
          assert_not_equal(user.id, c1.updater_id)
        end
      end

      should "not allow duplicate votes" do
        user = FactoryGirl.create(:user)
        post = FactoryGirl.create(:post)
        c1 = FactoryGirl.create(:comment, :post => post)

        assert_nothing_raised { c1.vote!("down") }
        exception = assert_raises(ActiveRecord::RecordInvalid) { c1.vote!("down") }
        assert_equal("Validation failed: You have already voted for this comment", exception.message)
        assert_equal(1, CommentVote.count)
        assert_equal(-1, CommentVote.last.score)

        c2 = FactoryGirl.create(:comment, :post => post)
        assert_nothing_raised { c2.vote!("down") }
        assert_equal(2, CommentVote.count)
      end

      should "not allow upvotes by the creator" do
        user = FactoryGirl.create(:user)
        post = FactoryGirl.create(:post)
        c1 = FactoryGirl.create(:comment, :post => post)

        exception = assert_raises(ActiveRecord::RecordInvalid) { c1.vote!("up") }
        assert_equal("Validation failed: You cannot upvote your own comments", exception.message)
      end

      should "allow undoing of votes" do
        user = FactoryGirl.create(:user)
        post = FactoryGirl.create(:post)
        comment = FactoryGirl.create(:comment, :post => post)
        CurrentUser.scoped(user, "127.0.0.1") do
          comment.vote!("up")
          comment.unvote!
          comment.reload
          assert_equal(0, comment.score)
          assert_nothing_raised {comment.vote!("down")}
        end
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

      should "default to id_desc order when searched with no options specified" do
        comms = FactoryGirl.create_list(:comment, 3)
        matches = Comment.search({})

        assert_equal([comms[2].id, comms[1].id, comms[0].id], matches.map(&:id))
      end

      context "that is edited by a moderator" do
        setup do
          @post = FactoryGirl.create(:post)
          @comment = FactoryGirl.create(:comment, :post_id => @post.id)
          @mod = FactoryGirl.create(:moderator_user)
          CurrentUser.user = @mod
        end

        should "create a mod action" do
          assert_difference("ModAction.count") do
            @comment.update_attributes({:body => "nope"}, :as => :moderator)
          end
        end
      end

      context "that is below the score threshold" do
        should "be hidden if not stickied" do
          user = FactoryGirl.create(:user, :comment_threshold => 0)
          post = FactoryGirl.create(:post)
          comment = FactoryGirl.create(:comment, :post => post, :score => -5)

          assert_equal([comment], post.comments.hidden(user))
          assert_equal([], post.comments.visible(user))
        end

        should "be visible if stickied" do
          user = FactoryGirl.create(:user, :comment_threshold => 0)
          post = FactoryGirl.create(:post)
          comment = FactoryGirl.create(:comment, :post => post, :score => -5, :is_sticky => true)

          assert_equal([], post.comments.hidden(user))
          assert_equal([comment], post.comments.visible(user))
        end
      end

      context "that is quoted" do
        should "strip [quote] tags correctly" do
          comment = FactoryGirl.create(:comment, body: <<-EOS.strip_heredoc)
            paragraph one

            [quote]
            somebody said:

            blah blah blah
            [/QUOTE]

            paragraph two
          EOS

          assert_equal(<<-EOS.strip_heredoc, comment.quoted_response)
            [quote]
            #{comment.creator_name} said:

            paragraph one

            paragraph two
            [/quote]

          EOS
        end
      end
    end
  end
end
