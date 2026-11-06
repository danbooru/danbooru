require "test_helper"

class PostVersionTest < ActiveSupport::TestCase
  context "A post" do
    setup do
      travel_to(1.month.ago) do
        @user = create(:user)
      end
      CurrentUser.user = @user
    end

    teardown do
      CurrentUser.user = nil
    end

    context "that has multiple versions: " do
      setup do
        @post = create(:post, tag_string: "1")
        travel(2.hours)
        @post.update(tag_string: "1 2")
        travel(2.hours)
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

      context "searching for changed tags" do
        should "find versions that added or removed all of the given tags" do
          v1, v2, v3 = @post.versions.sort_by(&:id)

          assert_equal([v1, v3], PostVersion.changed_tags_include_all(["1"]).sort_by(&:id))
          assert_equal([v2], PostVersion.changed_tags_include_all(["2"]).sort_by(&:id))
          assert_equal([v3], PostVersion.changed_tags_include_all(["1", "3"]).sort_by(&:id))
          assert_equal([], PostVersion.changed_tags_include_all(["1", "2"]).to_a)
          assert_equal([v1, v2, v3], PostVersion.changed_tags_include_any(["1", "2"]).sort_by(&:id))
        end

        should "not allow searching for more than 100 tags" do
          tags = (1..101).map { |n| "t#{n}" }

          assert_nothing_raised { PostVersion.changed_tags_include_all(tags.first(100)).to_a }
          assert_nothing_raised { PostVersion.changed_tags_include_any(tags.first(100)).to_a }
          assert_raises(ArgumentError) { PostVersion.changed_tags_include_all(tags) }
          assert_raises(ArgumentError) { PostVersion.changed_tags_include_any(tags) }
        end
      end
    end

    should "merge versions made by the same user within the same second" do
      @post = create(:post, tag_string: "aaa")
      second = 2.hours.from_now.change(usec: 0)
      travel_to(second + 0.1, with_usec: true) { @post.update!(tag_string: "aaa bbb") }
      travel_to(second + 0.5, with_usec: true) { @post.update!(tag_string: "aaa bbb ccc") }

      assert_equal(2, @post.versions.size)
      assert_equal(%w[bbb ccc], @post.versions.last.added_tags)
    end

    context "that has been created" do
      setup do
        @parent = create(:post)
        @post = create(:post, tag_string: "aaa bbb ccc", rating: "e", parent: @parent, source: "http://xyz.com")
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
        @parent = create(:post)
        @post = create(:post, tag_string: "aaa bbb ccc", rating: "q", source: "http://xyz.com")
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
        assert_equal([@pool.id], @post.pools.pluck(:id))

        assert_equal(1, @post.versions.size)
        assert_equal("tagme", @post.versions.last.tags)
      end
    end

    context "that has been updated" do
      setup do
        @post = create(:post, created_at: 1.minute.ago, tag_string: "aaa bbb ccc", rating: "q", source: "http://xyz.com")
        travel(2.hours)
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
        @post.stubs(:update_tag_category_counts).raises(NotImplementedError)

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
        @post = create(:post, tag_string: "1")
        travel(2.hours)
        @post.update(tag_string: "1 2")
        travel(2.hours)
        @post.update(tag_string: "2 3")
      end

      should "undo the changes" do
        @post.versions[1].undo!
        assert_equal("3", @post.reload.tag_string)
      end
    end
  end
end
