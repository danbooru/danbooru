class PostAppealsController < ApplicationController
  before_filter :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def new
    @post_appeal = PostAppeal.new
    respond_with(@post_appeal)
  end

  def index
    @post_appeals = PostAppeal.includes(:creator).search(params[:search]).includes(post: [:appeals, :uploader, :approver])
    @post_appeals = @post_appeals.paginate(params[:page], limit: params[:limit])
    respond_with(@post_appeals) do |format|
      format.xml do
        render :xml => @post_appeals.to_xml(:root => "post-appeals")
      end
    end
  end

  def create
    @post_appeal = PostAppeal.create(params[:post_appeal])
    respond_with(@post_appeal)
  end

  def show
    @post_appeal = PostAppeal.find(params[:id])
    @parent_post_set = PostSets::PostRelationship.new(@post_appeal.post.parent_id, :include_deleted => true)
    @children_post_set = PostSets::PostRelationship.new(@post_appeal.post.id, :include_deleted => true)
    respond_with(@post_appeal)
  end
end
