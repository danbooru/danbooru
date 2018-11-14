require 'test_helper'

class SavedSearchTest < ActiveSupport::TestCase
  def setup
    super
    @user = FactoryBot.create(:user)
    CurrentUser.user = @user
    CurrentUser.ip_addr = "127.0.0.1"
    @mock_redis = MockRedis.new
    SavedSearch.stubs(:redis).returns(@mock_redis)
  end

  def teardown
    super
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context ".labels_for" do
    setup do
      FactoryBot.create(:saved_search, user: @user, label_string: "blah", query: "blah")
      FactoryBot.create(:saved_search, user: @user, label_string: "zah", query: "blah")
    end

    should "fetch the labels used by a user" do
      assert_equal(%w(blah zah), SavedSearch.labels_for(@user.id))
    end
  end

  context ".queries_for" do
    setup do
      FactoryBot.create(:tag_alias, antecedent_name: "bbb", consequent_name: "ccc", creator: @user)
      FactoryBot.create(:saved_search, user: @user, label_string: "blah", query: "aaa")
      FactoryBot.create(:saved_search, user: @user, label_string: "zah", query: "CCC BBB AAA")
      FactoryBot.create(:saved_search, user: @user, label_string: "qux", query: " aaa  bbb  ccc ")
    end

    should "fetch the queries used by a user for a label" do
      assert_equal(%w(aaa), SavedSearch.queries_for(@user.id, label: "blah"))
    end

    should "fetch the queries used by a user without a label" do
      assert_equal(["aaa", "aaa ccc"], SavedSearch.queries_for(@user.id))
    end
  end

  context ".search_labels" do
    setup do
      FactoryBot.create(:tag_alias, antecedent_name: "bbb", consequent_name: "ccc", creator: @user)
      FactoryBot.create(:saved_search, user: @user, label_string: "blah", query: "aaa")
      FactoryBot.create(:saved_search, user: @user, label_string: "blahbling", query: "CCC BBB AAA")
      FactoryBot.create(:saved_search, user: @user, label_string: "qux", query: " aaa  bbb  ccc ")
    end

    should "fetch the queries used by a user for a label" do
      assert_equal(%w(blah blahbling), SavedSearch.search_labels(@user.id, label: "blah"))
    end
  end

  context ".post_ids_for" do
    context "with a label" do
      setup do
        SavedSearch.expects(:queries_for).with(1, label: "blah").returns(%w(a b c))
      end

      context "without a primed cache" do
        should "delay processing three times" do
          SavedSearch.expects(:populate).times(3)
          post_ids = SavedSearch.post_ids_for(1, label: "blah")
          assert_equal([], post_ids)
        end
      end

      context "with a primed cached" do
        setup do
          @mock_redis.sadd("search:a", 1)
          @mock_redis.sadd("search:b", 2)
          @mock_redis.sadd("search:c", 3)
        end

        should "fetch the post ids" do
          SavedSearch.expects(:delay).never
          post_ids = SavedSearch.post_ids_for(1, label: "blah")
          assert_equal([1,2,3], post_ids)
        end
      end
    end

    context "without a label" do
      setup do
        SavedSearch.expects(:queries_for).with(1, label: nil).returns(%w(a b c))
      end

      context "without a primed cache" do
        should "delay processing three times" do
          SavedSearch.expects(:populate).times(3)
          post_ids = SavedSearch.post_ids_for(1)
          assert_equal([], post_ids)
        end
      end

      context "with a primed cache" do
        setup do
          @mock_redis.sadd("search:a", 1)
          @mock_redis.sadd("search:b", 2)
          @mock_redis.sadd("search:c", 3)
        end

        should "fetch the post ids" do
          SavedSearch.expects(:delay).never
          post_ids = SavedSearch.post_ids_for(1)
          assert_equal([1,2,3], post_ids)
        end
      end
    end
  end

  context "Creating a saved search" do
    setup do
      FactoryBot.create(:tag_alias, antecedent_name: "zzz", consequent_name: "yyy", creator: @user)
      @saved_search = @user.saved_searches.create(query: " ZZZ xxx ")
    end

    should "update the bitpref on the user" do
      @user.reload
      assert(@user.has_saved_searches?, "should have saved_searches bitpref set")
    end

    should "normalize the query aside from the order" do
      assert_equal("yyy xxx", @saved_search.query)
    end

    should "normalize the label string" do
      @saved_search.label_string = "Foo Bar"
      assert_equal(%w[foo bar], @saved_search.labels)

      @saved_search.labels = ["Artist 1", "Artist 2"]
      assert_equal(%w[artist_1 artist_2], @saved_search.labels)
    end
  end

  context "Destroying a saved search" do
    setup do
      @saved_search = @user.saved_searches.create(query: "xxx")
      @saved_search.destroy
    end

    should "update the bitpref on the user" do
      @user.reload
      assert(!@user.has_saved_searches?, "should not have the saved_searches bitpref set")
    end
  end

  context "A user with max saved searches" do
    setup do
      @user = FactoryBot.create(:gold_user)
      CurrentUser.user = @user
      User.any_instance.stubs(:max_saved_searches).returns(0)
      @saved_search = @user.saved_searches.create(:query => "xxx")
    end

    should "not be able to create another saved search" do
      assert_equal(["You can only have up to 0 saved searches"], @saved_search.errors.full_messages)
    end
  end
end
