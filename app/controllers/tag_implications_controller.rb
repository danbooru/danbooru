class TagImplicationsController < ApplicationController
  before_filter :admin_only, :only => [:new, :create, :destroy]
  respond_to :html, :xml, :json, :js
  
  def new
    @tag_implication = TagImplication.new
    respond_with(@tag_implication)
  end
  
  def index
    @search = TagImplication.search(params[:search])
    @tag_implications = @search.paginate(:page => params[:page])
    respond_with(@tag_implicationes)
  end
  
  def create
    @tag_implication = TagImplication.create(params[:tag_implication])
    respond_with(@tag_implication, :location => tag_implications_path(:search => {:id_eq => @tag_implication.id}))
  end
  
  def destroy
    @tag_implication = TagImplication.find(params[:id])
    @tag_implication.destroy
    respond_with(@tag_implication)
  end
end
