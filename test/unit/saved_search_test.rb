require 'test_helper'
require 'helpers/saved_search_test_helper'
require 'fakeweb'

class SavedSearchTest < ActiveSupport::TestCase
  include SavedSearchTestHelper

  def setup
    super
    mock_saved_search_service!
  end

  context ".labels_for" do
    setup do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:saved_search, user: @user, label_string: "blah", query: "blah")
      FactoryGirl.create(:saved_search, user: @user, label_string: "zah", query: "blah")
    end

    should "fetch the labels used by a user" do
      assert_equal(%w(blah zah), SavedSearch.labels_for(@user.id))
    end

    should "expire when a search is updated" do
      Cache.expects(:delete).once
      FactoryGirl.create(:saved_search, user: @user, query: "blah")
    end
  end

  context ".queries_for" do
    setup do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:tag_alias, antecedent_name: "bbb", consequent_name: "ccc", creator: @user)
      FactoryGirl.create(:saved_search, user: @user, label_string: "blah", query: "aaa")
      FactoryGirl.create(:saved_search, user: @user, label_string: "zah", query: "CCC BBB AAA")
      FactoryGirl.create(:saved_search, user: @user, label_string: "qux", query: " aaa  bbb  ccc ")
    end

    should "fetch the queries used by a user for a label" do
      assert_equal(%w(aaa), SavedSearch.queries_for(@user.id, "blah"))
    end

    should "return fully normalized queries" do
      assert_equal(["aaa", "aaa ccc"], SavedSearch.queries_for(@user.id))
    end
  end

  context "Fetching the post ids for a search" do
    teardown do
      FakeWeb.clean_registry
    end

    context "with a label" do
      setup do
        SavedSearch.expects(:queries_for).with(1, "blah").returns(%w(a b c))
        FakeWeb.register_uri(:post, "http://localhost:3001/v2/search", :body => "1 2 3 4")
      end

      should "return a list of ids" do
        post_ids = SavedSearch.post_ids(1, "blah")
        assert_equal([1,2,3,4], post_ids)
      end
    end

    context "without a label" do
      setup do
        SavedSearch.expects(:queries_for).with(1, nil).returns(%w(a b c))
        FakeWeb.register_uri(:post, "http://localhost:3001/v2/search", :body => "1 2 3 4")
      end

      should "return a list of ids" do
        post_ids = SavedSearch.post_ids(1)
        assert_equal([1,2,3,4], post_ids)
      end
    end

    context "with a nonexistent label" do
      setup do
        SavedSearch.expects(:queries_for).with(1, "empty").returns([])
      end

      should "return an empty list of ids" do
        post_ids = SavedSearch.post_ids(1, "empty")
        assert_equal([], post_ids)
      end
    end
  end

  context "Creating a saved search" do
    setup do
      @user = FactoryGirl.create(:gold_user)
      FactoryGirl.create(:tag_alias, antecedent_name: "zzz", consequent_name: "yyy", creator: @user)
      @saved_search = @user.saved_searches.create(:query => " ZZZ xxx ")
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
      @user = FactoryGirl.create(:gold_user)
      @saved_search = @user.saved_searches.create(:tag_query => "xxx")
      @saved_search.destroy
    end

    should "update the bitpref on the user" do
      @user.reload
      assert(!@user.has_saved_searches?, "should not have the saved_searches bitpref set")
    end
  end

  context "A user with max saved searches" do
    setup do
      @user = FactoryGirl.create(:gold_user)
      User.any_instance.stubs(:max_saved_searches).returns(0)
      @saved_search = @user.saved_searches.create(:query => "xxx")
    end

    should "not be able to create another saved search" do
      assert_equal(["You can only have up to 0 saved searches"], @saved_search.errors.full_messages)
    end
  end
end
