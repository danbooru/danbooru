require 'test_helper'

class PostKeeperManagerTest < ActiveSupport::TestCase
  subject { PostKeeperManager }

  context "#check_and_update" do
    context "when the connection is bad" do
      setup do
        @user = FactoryBot.create(:user)
        as(@user) do
          @post = FactoryBot.create(:post)
        end
        @post.stubs(:update_column).raises(ActiveRecord::StatementInvalid.new("can't get socket descriptor post_versions"))
      end

      should "retry" do
        PostArchive.connection.expects(:reconnect!)
        assert_raises(ActiveRecord::StatementInvalid) do
          subject.check_and_update(@post)        
        end
      end
    end
  end

  context "#check_and_assign" do
    setup do
      Timecop.travel(1.month.ago) do
        @alice = FactoryBot.create(:user)
        @bob = FactoryBot.create(:user)
        @carol = FactoryBot.create(:user)
      end
      PostArchive.sqs_service.stubs(:merge?).returns(false)

      CurrentUser.scoped(@alice) do
        @post = FactoryBot.create(:post)
      end
      CurrentUser.scoped(@bob) do
        Timecop.travel(2.hours.from_now) do
          @post.reload
          @post.update(tag_string: "aaa bbb ccc")
        end
      end
      CurrentUser.scoped(@carol) do
        Timecop.travel(4.hours.from_now) do
          @post.reload
          @post.update(tag_string: "ccc ddd eee fff ggg")
        end
      end
    end

    should "update the post" do
      assert_equal(3, @post.versions.count)
      subject.check_and_assign(@post)
      assert_equal({"uid" => @carol.id}, @post.keeper_data)
    end
  end

  context "#check" do
    setup do
      Timecop.travel(1.month.ago) do
        @alice = FactoryBot.create(:user)
        @bob = FactoryBot.create(:user)
        @carol = FactoryBot.create(:user)
      end

      CurrentUser.scoped(@alice) do
        @post = FactoryBot.create(:post)
      end
    end

    should "find the most frequent tagger for a post" do
      assert_equal(@alice.id, subject.check(@post))
    end

    context "that is updated" do
      setup do
        CurrentUser.scoped(@bob) do
          Timecop.travel(2.hours.from_now) do
            @post.update_attributes(tag_string: "aaa bbb ccc")
          end
        end
      end

      should "find the most frequent tagger for a post" do
        assert_equal(@carol.id, subject.check(@post, @carol.id, %w(ddd eee fff ggg)))
      end
    end
  end
end
