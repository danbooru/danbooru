class SavedSearchesController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @saved_searches = saved_searches.paginated_search(params, count_pages: true).includes(model_includes(params))
    respond_with(@saved_searches)
  end

  def labels
    @labels = SavedSearch.search_labels(CurrentUser.id, params[:search]).take(params[:limit].to_i || 10)
    respond_with(@labels)
  end

  def create
    @saved_search = saved_searches.create(saved_search_params)
    respond_with(@saved_search)
  end

  def destroy
    @saved_search = saved_searches.find(params[:id])
    @saved_search.destroy
    respond_with(@saved_search)
  end

  def edit
    @saved_search = saved_searches.find(params[:id])
  end

  def update
    @saved_search = saved_searches.find(params[:id])
    @saved_search.update(saved_search_params)
    respond_with(@saved_search, :location => saved_searches_path)
  end

  private

  def saved_searches
    CurrentUser.user.saved_searches
  end

  def saved_search_params
    params.fetch(:saved_search, {}).permit(%i[query label_string disable_labels])
  end
end
