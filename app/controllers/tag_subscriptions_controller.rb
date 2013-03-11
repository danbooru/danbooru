class TagSubscriptionsController < ApplicationController
  before_filter :member_only, :only => [:new, :edit, :create, :update, :destroy]
  respond_to :html, :xml, :json
  rescue_from User::PrivilegeError, :with => "static/access_denied"

  def new
    @tag_subscription = TagSubscription.new
    respond_with(@tag_subscription)
  end
  
  def edit
    @tag_subscription = TagSubscription.find(params[:id])
    check_privilege(@tag_subscription)
    respond_with(@tag_subscription)
  end
  
  def index
    @user = CurrentUser.user
    @search = TagSubscription.owned_by(@user).order("name").search(params[:search])
    @tag_subscriptions = @search.paginate(params[:page])
    respond_with(@tag_subscriptions)
  end
  
  def create
    @tag_subscription = TagSubscription.create(params[:tag_subscription])
    respond_with(@tag_subscription) do |format|
      format.html do
        if @tag_subscription.errors.any?
          render :action => "new"
        else
          redirect_to tag_subscriptions_path
        end
      end
    end
  end
  
  def update
    @tag_subscription = TagSubscription.find(params[:id])
    check_privilege(@tag_subscription)
    @tag_subscription.update_attributes(params[:tag_subscription])
    respond_with(@tag_subscription) do |format|
      format.html do
        if @tag_subscription.errors.any?
          render :action => "edit"
        else
          redirect_to tag_subscriptions_path
        end
      end
    end
  end
  
  def destroy
    @tag_subscription = TagSubscription.find(params[:id])
    check_privilege(@tag_subscription)
    @tag_subscription.destroy
    respond_with(@tag_subscription)
  end
  
  def posts
    @user = User.find(params[:id])
    @post_set = PostSets::Post.new("sub:#{@user.name} #{params[:tags]}", params[:page])
    @posts = @post_set.posts
  end
  
private
  def check_privilege(tag_subscription)
    raise User::PrivilegeError unless tag_subscription.editable_by?(CurrentUser.user)
  end
end
