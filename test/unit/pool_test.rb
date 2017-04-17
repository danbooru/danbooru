# encoding: utf-8

require 'test_helper'
require 'helpers/pool_archive_test_helper'

class PoolTest < ActiveSupport::TestCase
  include PoolArchiveTestHelper

  setup do
    Timecop.travel(1.month.ago) do
      @user = FactoryGirl.create(:user)
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
      @pool = FactoryGirl.create(:pool, :name => "xxx")
    end

    should "be mapped to a pool id" do
      assert_equal(@pool.id, Pool.name_to_id("xxx"))
    end
  end

  context "A multibyte character name" do
    setup do
      @mb_pool = FactoryGirl.create(:pool, :name => "àáâãäå")
    end

    should "be mapped to a pool id" do
      assert_equal(@mb_pool.id, Pool.name_to_id("àáâãäå"))
    end
  end

  context "An id number" do
    setup do
      @pool = FactoryGirl.create(:pool)
    end

    should "be mapped to a pool id" do
      assert_equal(@pool.id, Pool.name_to_id(@pool.id.to_s))
    end

    should "be mapped to its name" do
      assert_equal(@pool.name, Pool.id_to_name(@pool.id))
    end
  end

  context "Reverting a pool" do
    setup do
      PoolArchive.stubs(:enabled?).returns(true)

      @pool = FactoryGirl.create(:pool)
      @p1 = FactoryGirl.create(:post)
      @p2 = FactoryGirl.create(:post)
      @p3 = FactoryGirl.create(:post)
      CurrentUser.scoped(@user, "1.2.3.4") do
        @pool.add!(@p1)
      end
      CurrentUser.scoped(@user, "1.2.3.5") do
        @pool.add!(@p2)
      end
      CurrentUser.scoped(@user, "1.2.3.6") do
        @pool.add!(@p3)
      end
      CurrentUser.scoped(@user, "1.2.3.7") do
        @pool.remove!(@p1)
      end
      CurrentUser.scoped(@user, "1.2.3.8") do
        version = @pool.versions[1]
        @pool.revert_to!(version)
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
      assert_equal([@p1.id], @pool.post_id_array)
    end

    should "update any old posts that were removed" do
      @p2.reload
      assert_equal("", @p2.pool_string)
    end

    should "update any new posts that were added" do
      @p1.reload
      assert_equal("pool:#{@pool.id} pool:series", @p1.pool_string)
    end
  end

  context "Updating a pool" do
    setup do
      @pool = FactoryGirl.create(:pool)
      @p1 = FactoryGirl.create(:post)
      @p2 = FactoryGirl.create(:post)
    end

    context "by adding a new post" do
      setup do
        @pool.add!(@p1)
      end

      should "add the post to the pool" do
        assert_equal("#{@p1.id}", @pool.post_ids)
      end

      should "add the pool to the post" do
        assert_equal("pool:#{@pool.id} pool:series", @p1.pool_string)
      end

      should "increment the post count" do
        assert_equal(1, @pool.post_count)
      end

      context "to a pool that already has the post" do
        setup do
          @pool.add!(@p1)
        end

        should "not double add the post to the pool" do
          assert_equal("#{@p1.id}", @pool.post_ids)
        end

        should "not double add the pool to the post" do
          assert_equal("pool:#{@pool.id} pool:series", @p1.pool_string)
        end

        should "not double increment the post count" do
          assert_equal(1, @pool.post_count)
        end
      end

      context "to a deleted pool" do
        setup do
          @pool.update_attribute(:is_deleted, true)
          @pool.post_ids = "#{@pool.post_ids} #{@p2.id}"
          @pool.synchronize!
          @pool.save
          @pool.reload
          @p2.reload
        end

        should "add the post to the pool" do
          assert_equal("#{@p1.id} #{@p2.id}", @pool.post_ids)
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
          assert_equal("", @pool.post_ids)
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
          assert_equal("#{@p1.id}", @pool.post_ids)
        end

        should "not affect the post" do
          assert_equal("pool:#{@pool.id} pool:series", @p1.pool_string)
        end

        should "not affect the post count" do
          assert_equal(1, @pool.post_count)
        end
      end
    end

    should "create new versions for each distinct user" do
      assert_equal(1, @pool.versions.size)
      user2 = Timecop.travel(1.month.ago) {FactoryGirl.create(:user)}

      CurrentUser.scoped(user2, "127.0.0.2") do
        @pool.post_ids = "#{@p1.id}"
        @pool.save
      end

      @pool.reload
      assert_equal(2, @pool.versions.size)

      CurrentUser.scoped(user2, "127.0.0.3") do
        @pool.post_ids = "#{@p1.id} #{@p2.id}"
        @pool.save
      end

      @pool.reload
      assert_equal(3, @pool.versions.size)
    end

    should "should create a version if the name changes" do
      assert_difference("@pool.versions.size", 1) do
        @pool.update(name: "blah")
        assert_equal("blah", @pool.versions.last.name)
      end
      assert_equal(2, @pool.versions.size)
    end

    should "know what its post ids were previously" do
      @pool.post_ids = "#{@p1.id}"
      assert_equal("", @pool.post_ids_was)
      assert_equal([], @pool.post_id_array_was)
    end

    should "normalize its name" do
      @pool.update_attributes(:name => "A B")
      assert_equal("A_B", @pool.name)
    end

    should "normalize its post ids" do
      @pool.update_attributes(:post_ids => " 1  2 ")
      assert_equal("1 2", @pool.post_ids)
    end
  end

  context "An existing pool" do
    setup do
      @pool = FactoryGirl.create(:pool)
      @p1 = FactoryGirl.create(:post)
      @p2 = FactoryGirl.create(:post)
      @p3 = FactoryGirl.create(:post)
      @pool.add!(@p1)
      @pool.add!(@p2)
      @pool.add!(@p3)
      @p1_neighbors = @pool.neighbors(@p1)
      @pool.reload # clear cached neighbors
      @p2_neighbors = @pool.neighbors(@p2)
      @pool.reload # clear cached neighbors
      @p3_neighbors = @pool.neighbors(@p3)
    end

    context "that is synchronized" do
      setup do
        @pool.reload
        @pool.post_ids = "#{@p2.id}"
        @pool.synchronize!
      end

      should "update the pool" do
        @pool.reload
        assert_equal(1, @pool.post_count)
        assert_equal("#{@p2.id}", @pool.post_ids)
      end

      should "update the posts" do
        @p1.reload
        @p2.reload
        @p3.reload
        assert_equal("", @p1.pool_string)
        assert_equal("pool:#{@pool.id} pool:series", @p2.pool_string)
        assert_equal("", @p3.pool_string)
      end
    end

    should "find the neighbors for the first post" do
      assert_nil(@p1_neighbors.previous)
      assert_equal(@p2.id, @p1_neighbors.next)
    end

    should "find the neighbors for the middle post" do
      assert_equal(@p1.id, @p2_neighbors.previous)
      assert_equal(@p3.id, @p2_neighbors.next)
    end

    should "find the neighbors for the last post" do
      assert_equal(@p2.id, @p3_neighbors.previous)
      assert_nil(@p3_neighbors.next)
    end
  end

  context "An anonymous pool" do
    setup do
      user = Timecop.travel(1.month.ago) {FactoryGirl.create(:user)}
      CurrentUser.user = user
    end

    should "have a name starting with anon" do
      pool = Pool.create_anonymous
      assert_match(/^anon:\d+$/, pool.name)
    end
  end
end
