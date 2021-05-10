require 'test_helper'

class PostVersionTest < ActiveSupport::TestCase
  context "A post" do
    setup do
      travel_to(1.month.ago) do
        @user = FactoryBot.create(:user)
      end
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "that has multiple versions: " do
      setup do
        PostVersion.sqs_service.stubs(:merge?).returns(false)
        @post = FactoryBot.create(:post, :tag_string => "1")
        @post.update(tag_string: "1 2")
        @post.update(tag_string: "2 3")
      end

      context "a version record" do
        setup do
          @version = PostVersion.last
        end

        should "know its previous version" do
          assert_not_nil(@version.previous)
          assert_equal("1 2", @version.previous.tags)
        end
      end
    end

    context "that has been created" do
      setup do
        @parent = FactoryBot.create(:post)
        @post = FactoryBot.create(:post, :tag_string => "aaa bbb ccc", :rating => "e", :parent => @parent, :source => "xyz")
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
        @parent = FactoryBot.create(:post)
        @post = FactoryBot.create(:post, :tag_string => "aaa bbb ccc", :rating => "q", :source => "xyz")
      end

      should "delete the previous version" do
        assert_equal(1, @post.versions.count)
        @post.update(tag_string: "bbb ccc xxx", source: "")
        @post.reload
        assert_equal(1, @post.versions.count)
      end
    end

    context "that is tagged with a pool:<name> metatag" do
      setup do
        @pool = create(:pool)
        @post = create(:post, tag_string: "tagme pool:#{@pool.id}")
      end

      should "create a version" do
        assert_equal("tagme", @post.tag_string)
        assert_equal("pool:#{@pool.id}", @post.pool_string)

        assert_equal(1, @post.versions.size)
        assert_equal("tagme", @post.versions.last.tags)
      end
    end

    context "that has been updated" do
      setup do
        PostVersion.sqs_service.stubs(:merge?).returns(false)
        @post = create(:post, created_at: 1.minute.ago, tag_string: "aaa bbb ccc", rating: "q", source: "xyz")
        @post.update(tag_string: "bbb ccc xxx", source: "")
      end

      should "also create a version" do
        assert_equal(2, @post.versions.size)
        @version = @post.versions.last
        assert_equal("bbb ccc xxx", @version.tags)
        assert_equal("q", @version.rating)
        assert_equal("", @version.source)
        assert_nil(@version.parent_id)
      end

      should "not create a version if updating the post fails" do
        @post.stubs(:set_tag_counts).raises(NotImplementedError)

        assert_equal(2, @post.versions.size)
        assert_raise(NotImplementedError) { @post.update(rating: "s") }
        assert_equal(2, @post.versions.size)
      end

      should "should create a version if the rating changes" do
        assert_difference("@post.versions.size", 1) do
          @post.update(rating: "s")
          assert_equal("s", @post.versions.max_by(&:id).rating)
        end
      end

      should "should create a version if the source changes" do
        assert_difference("@post.versions.size", 1) do
          @post.update(source: "blah")
          assert_equal("blah", @post.versions.max_by(&:id).source)
        end
      end

      should "should create a version if the parent changes" do
        assert_difference("@post.versions.size", 1) do
          @parent = create(:post)
          @post.update(parent_id: @parent.id)
          assert_equal(@parent.id, @post.versions.max_by(&:id).parent_id)
        end
      end

      should "should create a version if the tags change" do
        assert_difference("@post.versions.size", 1) do
          @post.update(tag_string: "blah")
          assert_equal("blah", @post.versions.max_by(&:id).tags)
        end
      end
    end

    context "#undo" do
      setup do
        PostVersion.sqs_service.stubs(:merge?).returns(false)
        @post = create(:post, tag_string: "1")
        @post.update(tag_string: "1 2")
        @post.update(tag_string: "2 3")
      end

      should "undo the changes" do
        @post.versions[1].undo!
        assert_equal("3", @post.reload.tag_string)
      end
    end
  end
end
