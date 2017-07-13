class TagSubscriptionsController < ApplicationController
  before_filter :member_only, :only => [:destroy, :migrate]
  respond_to :html, :xml, :json

  def index
    @user = CurrentUser.user
    @query = TagSubscription.order("name").search(params[:search])
    @tag_subscriptions = @query.paginate(params[:page], :limit => params[:limit])
    respond_with(@tag_subscriptions)
  end

  def destroy
    @tag_subscription = TagSubscription.find(params[:id])
    check_privilege(@tag_subscription)
    @tag_subscription.destroy
    respond_with(@tag_subscription)
  end

  def migrate
    @tag_subscription = TagSubscription.find(params[:id])
    check_privilege(@tag_subscription)
    @tag_subscription.migrate_to_saved_searches
    flash[:notice] = "Tag subscription will be migrated to a saved search. Please wait a few minutes for the search to refresh."
    redirect_to tag_subscriptions_path
  end

private
  def check_privilege(tag_subscription)
    raise User::PrivilegeError unless tag_subscription.editable_by?(CurrentUser.user)
  end
end
