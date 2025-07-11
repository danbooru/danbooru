# frozen_string_literal: true

class UserNameChangeRequestsController < ApplicationController
  respond_to :html, :json, :xml

  skip_before_action :redirect_if_name_invalid?

  def new
    @user = params[:id].present? ? User.find(params[:id]) : CurrentUser.user
    @change_request = authorize UserNameChangeRequest.new(user: @user, **permitted_attributes(UserNameChangeRequest))
    respond_with(@change_request)
  end

  def create
    user = User.find(params.dig(:user_name_change_request, :user_id))
    @change_request = authorize UserNameChangeRequest.new(updater: CurrentUser.user, original_name: user.name, **permitted_attributes(UserNameChangeRequest))
    @change_request.save

    respond_with(@change_request, notice: "Name changed", location: @change_request.user)
  end

  def show
    @change_request = authorize UserNameChangeRequest.find(params[:id])
    respond_with(@change_request)
  end

  def index
    @change_requests = authorize UserNameChangeRequest.visible(CurrentUser.user).paginated_search(params)
    respond_with(@change_requests)
  end
end
