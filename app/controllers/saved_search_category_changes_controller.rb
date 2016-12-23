class SavedSearchCategoryChangesController < ApplicationController
  include SavedSearches::CheckAvailability

  before_filter :member_only
  respond_to :html

  def new
    @category = params[:old]
  end

  def create
    SavedSearch.rename(CurrentUser.user.id, params[:old], params[:new])
    flash[:notice] = "Saved searches will be renamed"
    redirect_to saved_searches_path
  end
end
