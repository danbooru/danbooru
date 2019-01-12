module SavedSearchTestHelper
  def mock_saved_search_service!
    SavedSearch.stubs(:enabled?).returns(true)
  end
end
