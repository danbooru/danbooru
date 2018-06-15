class IqdbQueriesController < ApplicationController
  respond_to :html, :json, :xml

  def show
    if params[:matches]
      @matches = JSON.parse(params[:matches])
      @matches = @matches.map {|x| [Post.find(x[0]), x[1]]}
    end

    respond_with(@matches)
  end
end
