class WikiPagesController < ApplicationController
  respond_to :html, :xml, :json, :js
  layout "sidebar"

  def new
    @wiki_page = authorize WikiPage.new(permitted_attributes(WikiPage))
    respond_with(@wiki_page)
  end

  def edit
    @wiki_page, _found_by = WikiPage.find_by_id_or_title(params[:id])
    authorize @wiki_page
    respond_with(@wiki_page)
  end

  def index
    if params[:title].present?
      redirect_to wiki_pages_path(search: { title_normalize: params[:title] }, redirect: true)
    else
      @wiki_pages = authorize WikiPage.paginated_search(params)
      respond_with(@wiki_pages)
    end
  end

  def search
    authorize WikiPage
    render layout: "default"
  end

  def show
    @wiki_page, found_by = WikiPage.find_by_id_or_title(params[:id])

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
    @wiki_page = authorize WikiPage.new(permitted_attributes(WikiPage))
    @wiki_page.save
    respond_with(@wiki_page)
  end

  def update
    @wiki_page, _found_by = WikiPage.find_by_id_or_title(params[:id])
    authorize @wiki_page

    @wiki_page.update(permitted_attributes(@wiki_page))
    flash[:notice] = @wiki_page.warnings.full_messages.join(".\n \n") if @wiki_page.warnings.any?

    respond_with(@wiki_page)
  end

  def destroy
    @wiki_page, _found_by = WikiPage.find_by_id_or_title(params[:id])
    authorize @wiki_page

    @wiki_page.update(is_deleted: true)
    respond_with(@wiki_page)
  end

  def revert
    @wiki_page, _found_by = WikiPage.find_by_id_or_title(params[:id])
    authorize @wiki_page

    @version = @wiki_page.versions.find(params[:version_id])
    @wiki_page.revert_to!(@version)
    flash[:notice] = "Page was reverted"
    respond_with(@wiki_page)
  end

  def show_or_new
    if params[:title].blank?
      redirect_to new_wiki_page_path(permitted_attributes(WikiPage))
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
end
