class WikiPageVersionsController < ApplicationController
  def index
    @search = WikiPageVersion.search(params[:search])
    @wiki_page_versions = @search.paginate(:page => params[:page])
  end
end
