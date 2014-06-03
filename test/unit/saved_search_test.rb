require 'test_helper'

class SavedSearchTest < ActiveSupport::TestCase
  context "Creating a saved search" do
    setup do
      @user = FactoryGirl.create(:user)
      @saved_search = @user.saved_searches.create(:tag_query => "xxx")
    end

    should "update the bitpref on the user" do
      @user.reload
      assert(@user.has_saved_searchs?, "should have saved_searches bitpref set")
    end
  end

  context "Destroying a saved search" do
    setup do
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
      assert_equal(["User can only have up to 0 saved searches"], @saved_search.errors.full_messages)
    end
  end
end
