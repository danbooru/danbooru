require 'test_helper'

class PostKeeperManagerTest < ActiveSupport::TestCase
  subject { PostKeeperManager }

  context "#check_and_update" do
    setup do
      Timecop.travel(1.month.ago) do
        @alice = FactoryGirl.create(:user)
        @bob = FactoryGirl.create(:user)
        @carol = FactoryGirl.create(:user)
      end
      PostArchive.sqs_service.stubs(:merge?).returns(false)

      CurrentUser.scoped(@alice) do
        @post = FactoryGirl.create(:post)
      end
      CurrentUser.scoped(@bob) do
        Timecop.travel(2.hours.from_now) do
          @post.update_attributes(tag_string: "aaa bbb ccc")
        end
      end
      CurrentUser.scoped(@carol) do
        Timecop.travel(4.hours.from_now) do
          @post.update_attributes(tag_string: "ccc ddd eee fff ggg")
        end
      end
    end

    should "update the post" do
      subject.check_and_update(@post.id)
      @post.reload
      assert_equal({"uid" => @carol.id}, @post.keeper_data)
    end
  end

  context "#check" do
    setup do
      Timecop.travel(1.month.ago) do
        @alice = FactoryGirl.create(:user)
        @bob = FactoryGirl.create(:user)
        @carol = FactoryGirl.create(:user)
      end

      CurrentUser.scoped(@alice) do
        @post = FactoryGirl.create(:post)
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
