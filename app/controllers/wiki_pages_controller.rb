class WikiPagesController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :except => [:index, :show]
  before_filter :moderator_only, :only => [:destroy]

  def new
    @wiki_page = WikiPage.new
    respond_with(@wiki_page)
  end
  
  def edit
    @wiki_page = WikiPage.find(params[:id])
    respond_with(@wiki_page)
  end
  
  def index
    @search = WikiPage.search(params[:search])
    @wiki_pages = @search.paginate(:page => params[:page])
  end
  
  def show
    @wiki_page = WikiPage.find(params[:id])
    respond_with(@wiki_page)
  end
  
  def create
    @wiki_page = WikiPage.create(params[:wiki_page])
    respond_with(@wiki_page)
  end
  
  def update
    @wiki_page = WikiPage.find(params[:id])
    @wiki_page.update_attributes(params[:wiki_page])
    respond_with(@wiki_page)
  end
  
  def destroy
    @wiki_page = WikiPage.find(params[:id])
    @wiki_page.destroy
    respond_with(@wiki_page)
  end
  
  def revert
    @wiki_page = WikiPage.find(params[:id])
    @version = WikiPageVersion.find(params[:version_id])
    @wiki_page.revert_to!(@version)
    respond_with(@wiki_page)
  end
end
