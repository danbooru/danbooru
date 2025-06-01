# frozen_string_literal: true

class UserActionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    if user_id = params[:user_id] || params.dig(:search, :user_id)
      @user = User.find(user_id)
    elsif user_name = params.dig(:search, :user_name)
      @user = User.find_by_name(user_name)
    end

    @user_actions = authorize UserAction.for_user(CurrentUser.user).paginated_search(params, defaults: { user_id: @user&.id }, count_pages: @user.present?)
    @user_actions = @user_actions.includes(:user, model: [:artist, :post, :note, :user, :creator, :banner, :bulk_update_request, :tag, :antecedent_tag, :consequent_tag, :model, :topic, :purchaser, :recipient, :forum_topic, forum_post: [:topic], comment: [:creator, :post]]) if request.format.html?

    respond_with(@user_actions)
  end

  def show
    @user_actions = authorize UserAction.find(params[:id])
    respond_with(@user_actions)
  end
end
