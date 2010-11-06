class PostHistoriesController < ApplicationController
  def index
    @search = PostHistory.search(params[:search])
    @histories = @search.paginate(:page => params[:page], :per_page => 20, :order => "updated_at DESC")
  end
end
