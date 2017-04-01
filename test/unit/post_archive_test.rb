require 'test_helper'

class PostArchiveTest < ActiveSupport::TestCase
  context "A post" do
    setup do
      Timecop.travel(1.month.ago) do
        @user = FactoryGirl.create(:user)
      end
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "#undo" do
      setup do
        PostArchive.sqs_service.stubs(:merge?).returns(false)
        @post = FactoryGirl.create(:post, :tag_string => "1")
        @post.update_attributes(:tag_string => "1 2")
        @post.update_attributes(:tag_string => "2 3")
      end

      subject { @post.versions[1] }

      should "undo the changes" do
        subject.undo!
        @post.reload
        assert_equal("3", @post.tag_string)
      end
    end

    context "that has multiple versions: " do
      setup do
        PostArchive.sqs_service.stubs(:merge?).returns(false)
        @post = FactoryGirl.create(:post, :tag_string => "1")
        @post.update_attributes(:tag_string => "1 2")
        @post.update_attributes(:tag_string => "2 3")
      end

      context "a version record" do
        setup do
          @version = PostArchive.last
        end

        should "know its previous version" do
          assert_not_nil(@version.previous)
          assert_equal("1 2", @version.previous.tags)
        end
      end
    end

    context "that has been created" do
      setup do
        @parent = FactoryGirl.create(:post)
        @post = FactoryGirl.create(:post, :tag_string => "aaa bbb ccc", :rating => "e", :parent => @parent, :source => "xyz")
      end

      should "also create a version" do
        assert_equal(1, @post.versions.size)
        @version = @post.versions.last
        assert_equal("aaa bbb ccc", @version.tags)
        assert_equal(@post.rating, @version.rating)
        assert_equal(@post.parent_id, @version.parent_id)
        assert_equal(@post.source, @version.source)
      end
    end

    context "that should be merged" do
      setup do
        @parent = FactoryGirl.create(:post)
        @post = FactoryGirl.create(:post, :tag_string => "aaa bbb ccc", :rating => "q", :source => "xyz")
      end

      should "delete the previous version" do
        assert_equal(1, @post.versions.count)
        @post.update_attributes(:tag_string => "bbb ccc xxx", :source => "")
        @post.reload
        assert_equal(1, @post.versions.count)
      end
    end

    context "that has been updated" do
      setup do
        PostArchive.sqs_service.stubs(:merge?).returns(false)
        @post = FactoryGirl.create(:post, :tag_string => "aaa bbb ccc", :rating => "q", :source => "xyz")
      end

      should "also create a version" do
        @post.update_attributes(:tag_string => "bbb ccc xxx", :source => "")

        assert_equal(2, @post.versions.size)
        @version = @post.versions.last
        assert_equal("bbb ccc xxx", @version.tags)
        assert_equal("q", @version.rating)
        assert_equal("", @version.source)
        assert_nil(@version.parent_id)
      end

      should "not create a version if updating the post fails" do
        @post.stubs(:apply_post_metatags).raises(NotImplementedError)

        assert_raise(NotImplementedError) { @post.update(rating: "s") }
        assert_equal(1, @post.versions.size)
      end

      should "should create a version if the rating changes" do
        assert_difference("@post.versions.size", 1) do
          @post.update(rating: "s")
          assert_equal("s", @post.versions.last.rating)
        end
      end

      should "should create a version if the source changes" do
        assert_difference("@post.versions.size", 1) do
          @post.update(source: "blah")
          assert_equal("blah", @post.versions.last.source)
        end
      end

      should "should create a version if the parent changes" do
        assert_difference("@post.versions.size", 1) do
          @parent = FactoryGirl.create(:post)
          @post.update(parent_id: @parent.id)
          assert_equal(@parent.id, @post.versions.last.parent_id)
        end
      end

      should "should create a version if the tags change" do
        assert_difference("@post.versions.size", 1) do
          @post.update(tag_string: "blah")
          assert_equal("blah", @post.versions.last.tags)
        end
      end
    end
  end
end
