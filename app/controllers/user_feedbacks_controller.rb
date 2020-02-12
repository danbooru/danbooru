class UserFeedbacksController < ApplicationController
  before_action :gold_only, :only => [:new, :edit, :create, :update]
  respond_to :html, :xml, :json, :js

  def new
    @user_feedback = UserFeedback.new(user_feedback_params(:create))
    respond_with(@user_feedback)
  end

  def edit
    @user_feedback = UserFeedback.visible.find(params[:id])
    check_privilege(@user_feedback)
    respond_with(@user_feedback)
  end

  def show
    @user_feedback = UserFeedback.visible.find(params[:id])
    respond_with(@user_feedback)
  end

  def index
    @user_feedbacks = UserFeedback.paginated_search(params, count_pages: true).includes(model_includes(params))
    respond_with(@user_feedbacks)
  end

  def create
    @user_feedback = UserFeedback.create(user_feedback_params(:create).merge(creator: CurrentUser.user))
    respond_with(@user_feedback)
  end

  def update
    @user_feedback = UserFeedback.visible.find(params[:id])
    check_privilege(@user_feedback)
    @user_feedback.update(user_feedback_params(:update, @user_feedback))
    respond_with(@user_feedback)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:user, :creator]
    end
  end

  def check_privilege(user_feedback)
    raise User::PrivilegeError unless user_feedback.editable_by?(CurrentUser.user)
  end

  def user_feedback_params(context, user_feedback = nil)
    permitted_params = %i[body category]
    permitted_params += %i[user_id user_name] if context == :create
    permitted_params += %i[is_deleted] if context == :update && user_feedback.deletable_by?(CurrentUser.user)

    params.fetch(:user_feedback, {}).permit(permitted_params)
  end
end
