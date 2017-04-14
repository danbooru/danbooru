class TagSubscriptionsController < ApplicationController
  before_filter :disable_feature, :only => [:create]
  before_filter :member_only, :only => [:new, :edit, :create, :update, :destroy, :migrate]
  respond_to :html, :xml, :json

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
    @query = TagSubscription.order("name").search(params[:search])
    @tag_subscriptions = @query.paginate(params[:page], :limit => params[:limit])
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

  def migrate
    @tag_subscription = TagSubscription.find(params[:id])
    check_privilege(@tag_subscription)
    @tag_subscription.migrate_to_saved_searches
    flash[:notice] = "Tag subscription will be migrated to a saved search. Please wait a few minutes for the search to refresh."
    redirect_to tag_subscriptions_path
  end

private
  def disable_feature
    flash[:notice] = "Tag subscriptions are disabled"
    redirect_to tag_subscriptions_path
    return false
  end

  def check_privilege(tag_subscription)
    raise User::PrivilegeError unless tag_subscription.editable_by?(CurrentUser.user)
  end
end
