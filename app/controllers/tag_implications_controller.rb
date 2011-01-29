class TagImplicationsController < ApplicationController
  before_filter :admin_only, :only => [:new, :edit, :create, :update, :destroy]
  respond_to :html, :xml, :json
  
  def new
    @tag_implication = TagImplication.new
    respond_with(@tag_implication)
  end
  
  def edit
    @tag_implication = TagImplication.find(params[:id])
    respond_with(@tag_implication)
  end
  
  def index
    @search = TagImplication.search(params[:search])
    @tag_implicationes = @search.paginate(:page => params[:page])
    respond_with(@tag_implicationes)
  end
  
  def create
    @tag_implication = TagImplication.create(params[:tag_implication])
    respond_with(@tag_implication)
  end
  
  def update
    @tag_implication = TagImplication.find(params[:id])
    @tag_implication.update_attributes(params[:tag_implication])
    respond_with(@tag_implication)
  end
  
  def destroy
    @tag_implication = TagImplication.find(params[:id])
    @tag_implication.destroy
    respond_with(@tag_implication)
  end
end
