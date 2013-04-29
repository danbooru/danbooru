class TagsController < ApplicationController
  before_filter :member_only, :only => [:edit, :update]
  respond_to :html, :xml, :json

  def edit
    @tag = Tag.find(params[:id])
    check_privilege(@tag)
    respond_with(@tag)
  end

  def index
    @tags = Tag.search(params[:search]).paginate(params[:page], :search_count => params[:search])
    respond_with(@tags) do |format|
      format.xml do
        render :xml => @tags.to_xml(:root => "tags")
      end
    end
  end

  def search
  end

  def show
    @tag = Tag.find(params[:id])
    respond_with(@tag)
  end

  def update
    @tag = Tag.find(params[:id])
    check_privilege(@tag)
    @tag.update_attributes(params[:tag])
    @tag.update_category_cache_for_all
    respond_with(@tag)
  end

private
  def check_privilege(tag)
    raise User::PrivilegeError unless tag.editable_by?(CurrentUser.user)
  end
end
