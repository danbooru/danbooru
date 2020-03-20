class SavedSearchesController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @saved_searches = authorize SavedSearch.where(user: CurrentUser.user).paginated_search(params, count_pages: true)
    respond_with(@saved_searches)
  end

  def labels
    authorize SavedSearch
    @labels = SavedSearch.search_labels(CurrentUser.id, params[:search]).take(params[:limit].to_i || 10)
    respond_with(@labels)
  end

  def create
    @saved_search = authorize SavedSearch.new(user: CurrentUser.user, **permitted_attributes(SavedSearch))
    @saved_search.save
    respond_with(@saved_search)
  end

  def destroy
    @saved_search = authorize SavedSearch.find(params[:id])
    @saved_search.destroy
    respond_with(@saved_search)
  end

  def edit
    @saved_search = authorize SavedSearch.find(params[:id])
    respond_with(@saved_search)
  end

  def update
    @saved_search = authorize SavedSearch.find(params[:id])
    @saved_search.update(permitted_attributes(@saved_search))
    respond_with(@saved_search, :location => saved_searches_path)
  end
end
