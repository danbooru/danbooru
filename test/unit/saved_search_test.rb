require 'test_helper'
require 'helpers/saved_search_test_helper'
require 'fakeweb'

class SavedSearchTest < ActiveSupport::TestCase
  include SavedSearchTestHelper

  def setup
    super
    mock_saved_search_service!
    Danbooru.config.stubs(:listbooru_auth_key).returns("blahblahblah")
    Danbooru.config.stubs(:listbooru_server).returns("http://localhost:3001")
  end

  context "Fetching the post ids for a search" do
    setup do
      MEMCACHE.expects(:get).returns(nil)
    end

    teardown do
      FakeWeb.clean_registry
    end

    context "with a name" do
      setup do
        FakeWeb.register_uri(:get, "http://localhost:3001/users?key=blahblahblah&user_id=1&name=blah", :body => [1,2,3,4].to_json)
      end

      should "return a list of ids" do
        post_ids = SavedSearch.post_ids(1, "blah")
        assert_equal([1,2,3,4], post_ids)
      end
    end

    context "without a name" do
      setup do
        FakeWeb.register_uri(:get, "http://localhost:3001/users?key=blahblahblah&user_id=1&name", :body => [1,2,3,4].to_json)
      end

      should "return a list of ids" do
        post_ids = SavedSearch.post_ids(1)
        assert_equal([1,2,3,4], post_ids)
      end
    end
  end

  context "Creating a saved search" do
    setup do
      @user = FactoryGirl.create(:gold_user)
      @saved_search = @user.saved_searches.create(:tag_query => " xxx ")
    end

    should "update the bitpref on the user" do
      @user.reload
      assert(@user.has_saved_searches?, "should have saved_searches bitpref set")
    end

    should "normalize whitespace" do
      assert_equal("xxx", @saved_search.tag_query)
    end

    should "send messages" do
      assert_equal(%w(create), SavedSearch.sqs_service.commands)
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

    should "send messages" do
      assert_equal(%w(create delete), SavedSearch.sqs_service.commands)
    end
  end

  context "A user with max saved searches" do
    setup do
      @user = FactoryGirl.create(:gold_user)
      User.any_instance.stubs(:max_saved_searches).returns(0)
      @saved_search = @user.saved_searches.create(:tag_query => "xxx")
    end

    should "not be able to create another saved search" do
      assert_equal(["You can only have up to 0 saved searches"], @saved_search.errors.full_messages)
    end
  end
end
