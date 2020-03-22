require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  context "A comment" do
    setup do
      user = FactoryBot.create(:user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "that mentions a user" do
      setup do
        @post = FactoryBot.create(:post)
        Danbooru.config.stubs(:member_comment_limit).returns(100)
      end

      context "added in an edit" do
        should "dmail the added user" do
          @user1 = FactoryBot.create(:user)
          @user2 = FactoryBot.create(:user)
          @comment = FactoryBot.create(:comment, :post_id => @post.id, :body => "@#{@user1.name}")

          assert_no_difference("@user1.dmails.count") do
            assert_difference("@user2.dmails.count") do
              @comment.body = "@#{@user1.name} @#{@user2.name}"
              @comment.save
            end
          end
        end
      end

      context "in a quote block" do
        setup do
          @user2 = FactoryBot.create(:user, :created_at => 2.weeks.ago)
        end

        should "not create a dmail" do
          assert_difference("Dmail.count", 0) do
            FactoryBot.create(:comment, :post_id => @post.id, :body => "[quote]@#{@user2.name}[/quote]")
          end

          assert_difference("Dmail.count", 0) do
            FactoryBot.create(:comment, :post_id => @post.id, :body => "[quote]@#{@user2.name}[/quote] blah [quote]@#{@user2.name}[/quote]")
          end

          assert_difference("Dmail.count", 0) do
            FactoryBot.create(:comment, :post_id => @post.id, :body => "[quote][quote]@#{@user2.name}[/quote][/quote]")
          end

          assert_difference("Dmail.count", 1) do
            FactoryBot.create(:comment, :post_id => @post.id, :body => "[quote]@#{@user2.name}[/quote] @#{@user2.name}")
          end
        end
      end

      context "outside a quote block" do
        setup do
          @user2 = FactoryBot.create(:user)
          @comment = FactoryBot.build(:comment, :post_id => @post.id, :body => "Hey @#{@user2.name} check this out!")
        end

        should "create a dmail" do
          assert_difference("Dmail.count", 1) do
            @comment.save
          end

          dmail = Dmail.last
          assert_equal(<<-EOS.strip_heredoc, dmail.body)
            @#{@comment.creator.name} mentioned you in a \"comment\":/posts/#{@comment.post_id}#comment-#{@comment.id} on post ##{@comment.post_id}:

            [quote]
            Hey @#{@user2.name} check this out!
            [/quote]
          EOS
        end
      end
    end

    context "created by an unlimited user" do
      setup do
        Danbooru.config.stubs(:member_comment_limit).returns(100)
      end

      context "that is then deleted" do
        setup do
          @post = FactoryBot.create(:post)
          @comment = FactoryBot.create(:comment, :post_id => @post.id)
          @comment.update(is_deleted: true)
          @post.reload
        end

        should "nullify the last_commented_at field" do
          assert_nil(@post.last_commented_at)
        end
      end

      should "not validate if the post does not exist" do
        comment = FactoryBot.build(:comment, :post_id => -1)

        assert_not(comment.valid?)
        assert_equal(["must exist"], comment.errors[:post])
      end

      should "not bump the parent post" do
        post = FactoryBot.create(:post)
        comment = FactoryBot.create(:comment, :do_not_bump_post => true, :post => post)
        post.reload
        assert_nil(post.last_comment_bumped_at)

        comment = FactoryBot.create(:comment, :post => post)
        post.reload
        assert_not_nil(post.last_comment_bumped_at)
      end

      should "not bump the post after exceeding the threshold" do
        Danbooru.config.stubs(:comment_threshold).returns(1)
        p = FactoryBot.create(:post)
        c1 = FactoryBot.create(:comment, :post => p)
        travel(2.seconds) do
          c2 = FactoryBot.create(:comment, :post => p)
        end
        p.reload
        assert_equal(c1.created_at.to_s, p.last_comment_bumped_at.to_s)
      end

      should "always record the last_commented_at properly" do
        post = FactoryBot.create(:post)
        Danbooru.config.stubs(:comment_threshold).returns(1)

        c1 = FactoryBot.create(:comment, :do_not_bump_post => true, :post => post)
        post.reload
        assert_equal(c1.created_at.to_s, post.last_commented_at.to_s)

        travel(2.seconds) do
          c2 = FactoryBot.create(:comment, :post => post)
          post.reload
          assert_equal(c2.created_at.to_s, post.last_commented_at.to_s)
        end
      end

      should "not record the user id of the voter" do
        user = FactoryBot.create(:user)
        post = FactoryBot.create(:post)
        c1 = FactoryBot.create(:comment, :post => post)
        CurrentUser.scoped(user, "127.0.0.1") do
          c1.vote!("up")
          c1.reload
          assert_not_equal(user.id, c1.updater_id)
        end
      end

      should "not allow duplicate votes" do
        user = FactoryBot.create(:user)
        post = FactoryBot.create(:post)
        c1 = FactoryBot.create(:comment, :post => post)

        assert_nothing_raised { c1.vote!("down") }
        exception = assert_raises(ActiveRecord::RecordInvalid) { c1.vote!("down") }
        assert_equal("Validation failed: You have already voted for this comment", exception.message)
        assert_equal(1, CommentVote.count)
        assert_equal(-1, CommentVote.last.score)

        c2 = FactoryBot.create(:comment, :post => post)
        assert_nothing_raised { c2.vote!("down") }
        assert_equal(2, CommentVote.count)
      end

      should "not allow upvotes by the creator" do
        user = FactoryBot.create(:user)
        post = FactoryBot.create(:post)
        c1 = create(:comment, post: post, creator: CurrentUser.user)

        exception = assert_raises(ActiveRecord::RecordInvalid) { c1.vote!("up") }
        assert_equal("Validation failed: You cannot upvote your own comments", exception.message)
      end

      should "allow undoing of votes" do
        user = FactoryBot.create(:user)
        post = FactoryBot.create(:post)
        comment = FactoryBot.create(:comment, :post => post)
        CurrentUser.scoped(user, "127.0.0.1") do
          comment.vote!("up")
          comment.unvote!
          comment.reload
          assert_equal(0, comment.score)
          assert_nothing_raised {comment.vote!("down")}
        end
      end

      should "be searchable" do
        c1 = FactoryBot.create(:comment, :body => "aaa bbb ccc")
        c2 = FactoryBot.create(:comment, :body => "aaa ddd")
        c3 = FactoryBot.create(:comment, :body => "eee")

        matches = Comment.search(body_matches: "aaa")
        assert_equal(2, matches.count)
        assert_equal(c2.id, matches.all[0].id)
        assert_equal(c1.id, matches.all[1].id)
      end

      should "default to id_desc order when searched with no options specified" do
        comms = FactoryBot.create_list(:comment, 3)
        matches = Comment.search({})

        assert_equal([comms[2].id, comms[1].id, comms[0].id], matches.map(&:id))
      end

      context "that is edited by a moderator" do
        setup do
          @post = FactoryBot.create(:post)
          @comment = FactoryBot.create(:comment, :post_id => @post.id)
          @mod = FactoryBot.create(:moderator_user)
          CurrentUser.user = @mod
        end

        should "create a mod action" do
          assert_difference("ModAction.count") do
            @comment.update(body: "nope")
          end
        end

        should "credit the moderator as the updater" do
          @comment.update(body: "test")
          assert_equal(@mod.id, @comment.updater_id)
        end
      end

      context "that is quoted" do
        should "strip [quote] tags correctly" do
          comment = FactoryBot.create(:comment, body: <<-EOS.strip_heredoc)
            paragraph one

            [quote]
            somebody said:

            blah blah blah
            [/QUOTE]

            paragraph two
          EOS

          assert_equal(<<-EOS.strip_heredoc, comment.quoted_response)
            [quote]
            #{comment.creator.name} said:

            paragraph one

            paragraph two
            [/quote]

          EOS
        end
      end
    end

    context "during validation" do
      subject { FactoryBot.build(:comment) }
      should_not allow_value(" ").for(:body)
    end
  end
end
