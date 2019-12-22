require 'test_helper'

class PoolTest < ActiveSupport::TestCase
  setup do
    travel_to(1.month.ago) do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
    end

    CurrentUser.ip_addr = "127.0.0.1"

    mock_pool_archive_service!
    PoolArchive.sqs_service.stubs(:merge?).returns(false)
    start_pool_archive_transaction
  end

  teardown do
    rollback_pool_archive_transaction
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "A name" do
    setup do
      @pool = FactoryBot.create(:pool, :name => "xxx")
    end

    should "be mapped to a pool id" do
      assert_equal(@pool.id, Pool.name_to_id("xxx"))
    end
  end

  context "A multibyte character name" do
    setup do
      @mb_pool = FactoryBot.create(:pool, :name => "àáâãäå")
    end

    should "be mapped to a pool id" do
      assert_equal(@mb_pool.id, Pool.name_to_id("àáâãäå"))
    end
  end

  context "An id number" do
    setup do
      @pool = FactoryBot.create(:pool)
    end

    should "be mapped to a pool id" do
      assert_equal(@pool.id, Pool.name_to_id(@pool.id.to_s))
    end
  end

  context "Searching pools" do
    should "find pools by name" do
      @pool = FactoryBot.create(:pool, name: "Test Pool")

      assert_equal(@pool.id, Pool.find_by_name("test pool").id)
      assert_equal(@pool.id, Pool.search(name_matches: "test pool").first.id)
    end

    should "find pools by post id" do
      @pool1 = create(:pool, name: "pool1")
      @pool2 = create(:pool, name: "pool2")
      @post1 = create(:post, tag_string: "pool:pool1")
      @post2 = create(:post, tag_string: "pool:pool2")

      assert_equal([@pool1.id], Pool.search(post_ids_include_any: @post1.id).pluck(:id))
      assert_equal([@pool2.id, @pool1.id], Pool.search(post_ids_include_any: "#{@post1.id} #{@post2.id}").pluck(:id))
    end

    should "find pools by post id count" do
      @pool1 = create(:pool, name: "pool1")
      @pool2 = create(:pool, name: "pool2")
      @post1 = create(:post, tag_string: "pool:pool1")
      @post2 = create(:post, tag_string: "pool:pool1")

      assert_equal([@pool1.id], Pool.search(post_id_count: 2).pluck(:id))
    end

    should "find pools by post tags" do
      @pool1 = create(:pool, name: "pool1")
      @pool2 = create(:pool, name: "pool2")
      @post1 = create(:post, tag_string: "pool:pool1 bkub")
      @post2 = create(:post, tag_string: "pool:pool1 fumimi")
      @post3 = create(:post, tag_string: "pool:pool2 bkub fumimi")

      assert_equal([@pool2.id, @pool1.id], Pool.search(post_tags_match: "bkub").pluck(:id))
      assert_equal([@pool2.id, @pool1.id], Pool.search(post_tags_match: "fumimi").pluck(:id))
      assert_equal([@pool2.id], Pool.search(post_tags_match: "bkub fumimi").pluck(:id))
    end
  end

  context "Creating a pool" do
    setup do
      @posts = FactoryBot.create_list(:post, 5)
      @pool = FactoryBot.create(:pool, post_ids: @posts.map(&:id))
    end

    should "initialize the post count" do
      assert_equal(@posts.size, @pool.post_count)
    end

    should "synchronize the posts with the pool" do
      assert_equal(@posts.map(&:id), @pool.post_ids)

      @posts.each(&:reload)
      assert_equal(["pool:#{@pool.id}"] * @posts.size, @posts.map(&:pool_string))
    end
  end

  context "Reverting a pool" do
    setup do
      PoolArchive.stubs(:enabled?).returns(true)

      @pool = FactoryBot.create(:pool)
      @p1 = FactoryBot.create(:post)
      @p2 = FactoryBot.create(:post)
      @p3 = FactoryBot.create(:post)
      CurrentUser.scoped(@user, "1.2.3.4") do
        @pool.add!(@p1)
        @pool.reload
      end
      CurrentUser.scoped(@user, "1.2.3.5") do
        @pool.add!(@p2)
        @pool.reload
      end
      CurrentUser.scoped(@user, "1.2.3.6") do
        @pool.add!(@p3)
        @pool.reload
      end
      CurrentUser.scoped(@user, "1.2.3.7") do
        @pool.remove!(@p1)
        @pool.reload
      end
      CurrentUser.scoped(@user, "1.2.3.8") do
        version = @pool.versions[1]
        @pool.revert_to!(version)
        @pool.reload
      end
    end

    should "have the correct versions" do
      assert_equal(6, @pool.versions.size)
      assert_equal([], @pool.versions.all[0].post_ids)
      assert_equal([@p1.id], @pool.versions.all[1].post_ids)
      assert_equal([@p1.id, @p2.id], @pool.versions.all[2].post_ids)
      assert_equal([@p1.id, @p2.id, @p3.id], @pool.versions.all[3].post_ids)
      assert_equal([@p2.id, @p3.id], @pool.versions.all[4].post_ids)
    end

    should "update its post_ids" do
      assert_equal([@p1.id], @pool.post_ids)
    end

    should "update any old posts that were removed" do
      @p2.reload
      assert_equal("", @p2.pool_string)
    end

    should "update any new posts that were added" do
      @p1.reload
      assert_equal("pool:#{@pool.id}", @p1.pool_string)
    end
  end

  context "Updating a pool" do
    setup do
      @pool = FactoryBot.create(:pool, category: "series")
      @p1 = FactoryBot.create(:post)
      @p2 = FactoryBot.create(:post)
    end

    context "by adding a new post" do
      setup do
        @pool.add!(@p1)
      end

      context "by #attributes=" do
        setup do
          @pool.attributes = {post_ids: [@p1.id, @p2.id]}
          @pool.synchronize
          @pool.save
        end

        should "initialize the post count" do
          assert_equal(2, @pool.post_count)
        end
      end

      should "add the post to the pool" do
        assert_equal([@p1.id], @pool.post_ids)
      end

      should "add the pool to the post" do
        assert_equal("pool:#{@pool.id}", @p1.pool_string)
      end

      should "increment the post count" do
        assert_equal(1, @pool.post_count)
      end

      context "to a pool that already has the post" do
        setup do
          @pool.add!(@p1)
        end

        should "not double add the post to the pool" do
          assert_equal([@p1.id], @pool.post_ids)
        end

        should "not double add the pool to the post" do
          assert_equal("pool:#{@pool.id}", @p1.pool_string)
        end

        should "not double increment the post count" do
          assert_equal(1, @pool.post_count)
        end
      end

      context "to a deleted pool" do
        setup do
          # must be a builder to update deleted pools.
          CurrentUser.user = FactoryBot.create(:builder_user)

          @pool.update_attribute(:is_deleted, true)
          @pool.post_ids += [@p2.id]
          @pool.synchronize!
          @pool.save
          @pool.reload
          @p2.reload
        end

        should "add the post to the pool" do
          assert_equal([@p1.id, @p2.id], @pool.post_ids)
        end

        should "add the pool to the post" do
          assert_equal("pool:#{@pool.id}", @p2.pool_string)
        end

        should "increment the post count" do
          assert_equal(2, @pool.post_count)
        end
      end
    end

    context "by removing a post" do
      setup do
        @pool.add!(@p1)
      end

      context "that is in the pool" do
        setup do
          @pool.remove!(@p1)
        end

        should "remove the post from the pool" do
          assert_equal([], @pool.post_ids)
        end

        should "remove the pool from the post" do
          assert_equal("", @p1.pool_string)
        end

        should "update the post count" do
          assert_equal(0, @pool.post_count)
        end
      end

      context "that is not in the pool" do
        setup do
          @pool.remove!(@p2)
        end

        should "not affect the pool" do
          assert_equal([@p1.id], @pool.post_ids)
        end

        should "not affect the post" do
          assert_equal("pool:#{@pool.id}", @p1.pool_string)
        end

        should "not affect the post count" do
          assert_equal(1, @pool.post_count)
        end
      end
    end

    should "create new versions for each distinct user" do
      assert_equal(1, @pool.versions.size)
      user2 = travel_to(1.month.ago) {FactoryBot.create(:user)}

      CurrentUser.scoped(user2, "127.0.0.2") do
        @pool.post_ids = [@p1.id]
        @pool.save
      end

      @pool.reload
      assert_equal(2, @pool.versions.size)
      assert_equal(user2.id, @pool.versions.last.updater_id)
      assert_equal("127.0.0.2", @pool.versions.last.updater_ip_addr.to_s)

      CurrentUser.scoped(user2, "127.0.0.3") do
        @pool.post_ids = [@p1.id, @p2.id]
        @pool.save
      end

      @pool.reload
      assert_equal(3, @pool.versions.size)
      assert_equal(user2.id, @pool.versions.last.updater_id)
      assert_equal("127.0.0.3", @pool.versions.last.updater_ip_addr.to_s)
    end

    should "should create a version if the name changes" do
      assert_difference("@pool.versions.size", 1) do
        @pool.update(name: "blah")
        assert_equal("blah", @pool.versions.last.name)
      end
      assert_equal(2, @pool.versions.size)
    end

    should "know what its post ids were previously" do
      @pool.post_ids = [@p1.id]
      assert_equal([], @pool.post_ids_was)
    end

    should "normalize its name" do
      @pool.update(:name => "  A  B  ")
      assert_equal("A_B", @pool.name)

      @pool.update(:name => "__A__B__")
      assert_equal("A_B", @pool.name)
    end

    should "normalize its post ids" do
      @pool.update(category: "collection", post_ids: [1, 2, 2, 3, 1])
      assert_equal([1, 2, 3], @pool.post_ids)
    end

    context "when validating names" do
      ["foo,bar", "foo*bar", "123", "___", "   ", "any", "none", "series", "collection"].each do |bad_name|
        should_not allow_value(bad_name).for(:name)
      end
    end
  end

  context "An existing pool" do
    setup do
      @pool = FactoryBot.create(:pool)
      @p1 = FactoryBot.create(:post)
      @p2 = FactoryBot.create(:post)
      @p3 = FactoryBot.create(:post)
      @pool.add!(@p1)
      @pool.add!(@p2)
      @pool.add!(@p3)
    end

    context "that is synchronized" do
      setup do
        @pool.reload
        @pool.post_ids = [@p2.id]
        @pool.synchronize!
      end

      should "update the pool" do
        @pool.reload
        assert_equal(1, @pool.post_count)
        assert_equal([@p2.id], @pool.post_ids)
      end

      should "update the posts" do
        @p1.reload
        @p2.reload
        @p3.reload
        assert_equal("", @p1.pool_string)
        assert_equal("pool:#{@pool.id}", @p2.pool_string)
        assert_equal("", @p3.pool_string)
      end
    end

    should "find the neighbors for the first post" do
      assert_nil(@pool.previous_post_id(@p1.id))
      assert_equal(@p2.id, @pool.next_post_id(@p1.id))
    end

    should "find the neighbors for the middle post" do
      assert_equal(@p1.id, @pool.previous_post_id(@p2.id))
      assert_equal(@p3.id, @pool.next_post_id(@p2.id))
    end

    should "find the neighbors for the last post" do
      assert_equal(@p2.id, @pool.previous_post_id(@p3.id))
      assert_nil(@pool.next_post_id(@p3.id))
    end
  end
end
