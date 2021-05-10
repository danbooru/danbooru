class UserFeedbacksController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @user_feedback = authorize UserFeedback.new(permitted_attributes(UserFeedback))
    respond_with(@user_feedback)
  end

  def edit
    @user_feedback = authorize UserFeedback.find(params[:id])
    respond_with(@user_feedback)
  end

  def show
    @user_feedback = authorize UserFeedback.find(params[:id])
    respond_with(@user_feedback)
  end

  def index
    @user_feedbacks = authorize UserFeedback.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @user_feedbacks = @user_feedbacks.includes(:user, :creator) if request.format.html?

    respond_with(@user_feedbacks)
  end

  def create
    @user_feedback = authorize UserFeedback.new(creator: CurrentUser.user, **permitted_attributes(UserFeedback))
    @user_feedback.save
    respond_with(@user_feedback)
  end

  def update
    @user_feedback = authorize UserFeedback.find(params[:id])
    @user_feedback.update(permitted_attributes(@user_feedback))
    respond_with(@user_feedback)
  end
end
