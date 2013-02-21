class WikiPageVersionsController < ApplicationController
  respond_to :json, :html, :xml
  
  def index
    @search = WikiPageVersion.search(params[:search])
    @wiki_page_versions = @search.order("id desc").paginate(params[:page])
    respond_with(@wiki_page_versions)
  end
  
  def show
    @wiki_page_version = WikiPageVersion.find(params[:id])
    respond_with(@wiki_page_version)
  end
end
