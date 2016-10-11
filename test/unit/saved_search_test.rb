require 'test_helper'

class SavedSearchTest < ActiveSupport::TestCase
  context "Fetching the post ids for a search" do
    setup do
      Danbooru.config.stubs(:listbooru_enabled?).returns(true)
      Danbooru.config.stubs(:listbooru_auth_key).returns("blahblahblah")
      Danbooru.config.stubs(:listbooru_server).returns("http://localhost:3001")
    end

    context "with a name" do
      should "return a list of ids" do
        MEMCACHE.expects(:get).returns(nil)
        VCR.use_cassette("saved-search-test/get-named", :record => :none) do
          post_ids = SavedSearch.post_ids(1, "blah")
          assert_equal([1,2,3,4], post_ids)
        end
      end
    end

    context "without a name" do
      should "return a list of ids" do
        MEMCACHE.expects(:get).returns(nil)
        VCR.use_cassette("saved-search-test/get-unnamed", :record => :none) do
          post_ids = SavedSearch.post_ids(1)
          assert_equal([1,2,3,4], post_ids)
        end
      end
    end
  end

  context "Creating a saved search" do
    setup do
      @user = FactoryGirl.create(:user)
      @saved_search = @user.saved_searches.create(:tag_query => " xxx ")
    end

    should "update the bitpref on the user" do
      @user.reload
      assert(@user.has_saved_searches?, "should have saved_searches bitpref set")
    end

    should "normalize whitespace" do
      assert_equal("xxx", @saved_search.tag_query)
    end
  end

  context "Destroying a saved search" do
    setup do
      SqsService.any_instance.stubs(:send_message)
      @user = FactoryGirl.create(:user)
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
      @user = FactoryGirl.create(:user)
      User.any_instance.stubs(:max_saved_searches).returns(0)
      @saved_search = @user.saved_searches.create(:tag_query => "xxx")
    end

    should "not be able to create another saved search" do
      assert_equal(["You can only have up to 0 saved searches"], @saved_search.errors.full_messages)
    end
  end
end
