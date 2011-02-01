class UserFeedbackController < ApplicationController
  before_filter :privileged_only, :only => [:new, :edit, :create, :update, :destroy]
  respond_to :html, :xml, :json
  rescue_from User::PrivilegeError, :with => "static/access_denied"

  def new
    @user_feedback = UserFeedback.new
    respond_with(@user_feedback)
  end
  
  def edit
    @user_feedback = UserFeedback.find(params[:id])
    check_privilege(@user_feedback)
    respond_with(@user_feedback)
  end
  
  def index
    @search = UserFeedback.search(params[:search])
    @user_feedback = @search.paginate(:page => params[:page])
    respond_with(@user_feedback)
  end
  
  def create
    @user_feedback = UserFeedback.create(params[:user_feedback])
    respond_with(@user_feedback)
  end
  
  def destroy
    @user_feedback = UserFeedback.find(params[:id])
    check_privilege(@user_feedback)
    @user_feedback.destroy
    respond_with(@user_feedback, :location => user_feedback_path)
  end

private
  def check_privilege(user_feedback)
    raise User::PrivilegeError unless (user_feedback.creator_id == CurrentUser.id || CurrentUser.is_moderator?)
  end
end
