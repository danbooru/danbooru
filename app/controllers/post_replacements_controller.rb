class PostReplacementsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :approver_only, except: [:index]

  def index
    params[:search][:post_id] = params.delete(:post_id) if params.has_key?(:post_id)
    @post_replacements = PostReplacement.search(params[:search]).paginate(params[:page], limit: params[:limit])

    respond_with(@post_replacements)
  end
end
