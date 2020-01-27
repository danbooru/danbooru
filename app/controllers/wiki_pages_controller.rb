class WikiPagesController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only, :except => [:index, :search, :show, :show_or_new]
  before_action :normalize_search_params, :only => [:index]
  layout "sidebar"

  def new
    @wiki_page = WikiPage.new(wiki_page_params(:create))
    respond_with(@wiki_page)
  end

  def edit
    @wiki_page, _found_by = WikiPage.find_by_id_or_title(params[:id])
    respond_with(@wiki_page)
  end

  def index
    @wiki_pages = WikiPage.paginated_search(params)

    respond_with(@wiki_pages)
  end

  def search
    render layout: "default"
  end

  def show
    @wiki_page, found_by = WikiPage.find_by_id_or_title(params[:id])
    @current_item = @wiki_page
    if request.format.html? && @wiki_page.blank? && found_by == :title
      @wiki_page = WikiPage.new(title: params[:id])
      respond_with @wiki_page, status: 404
    elsif request.format.html? && @wiki_page.present? && found_by == :id
      redirect_to @wiki_page
    elsif @wiki_page.blank?
      raise ActiveRecord::RecordNotFound
    else
      respond_with(@wiki_page)
    end
  end

  def create
    @wiki_page = WikiPage.create(wiki_page_params(:create))
    respond_with(@wiki_page)
  end

  def update
    @wiki_page, _found_by = WikiPage.find_by_id_or_title(params[:id])
    @wiki_page.update(wiki_page_params(:update))
    flash[:notice] = @wiki_page.warnings.full_messages.join(".\n \n") if @wiki_page.warnings.any?

    respond_with(@wiki_page)
  end

  def destroy
    @wiki_page, _found_by = WikiPage.find_by_id_or_title(params[:id])
    @wiki_page.update(is_deleted: true)
    respond_with(@wiki_page)
  end

  def revert
    @wiki_page, _found_by = WikiPage.find_by_id_or_title(params[:id])
    @version = @wiki_page.versions.find(params[:version_id])
    @wiki_page.revert_to!(@version)
    flash[:notice] = "Page was reverted"
    respond_with(@wiki_page)
  end

  def show_or_new
    if params[:title].blank?
      redirect_to new_wiki_page_path(wiki_page_params(:create))
    else
      redirect_to wiki_page_path(params[:title])
    end
  end

  private

  def item_matches_params(wiki_page)
    if params[:search][:title_normalize]
      wiki_page.title == WikiPage.normalize_title(params[:search][:title_normalize])
    else
      true
    end
  end

  def normalize_search_params
    if params[:title]
      params[:search] ||= {}
      params[:search][:title] = params.delete(:title)
    end
  end

  def wiki_page_params(context)
    permitted_params = %i[title body other_names other_names_string is_deleted]
    permitted_params += %i[is_locked] if CurrentUser.is_builder?

    params.fetch(:wiki_page, {}).permit(permitted_params)
  end
end
