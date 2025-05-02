# frozen_string_literal: true

class UserEventsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @user = User.find(params[:user_id]) if params[:user_id].present?
    @defaults = { user_id: params[:user_id] }
    @mode = params[:mode] || (params[:user_id].present? ? "list" : "table")
    @user_events = authorize UserEvent.visible(CurrentUser.user).paginated_search(params, count_pages: true, defaults: @defaults)
    @user_events = @user_events.includes(:user, :ip_geolocation) if request.format.html?

    respond_with(@user_events)
  end

  def fingerprint
    @user_event = authorize UserEvent.find(params[:id])
    respond_with(@user_event)
  end

  def compare_fingerprint
    @user_event_a = authorize UserEvent.find(params[:id])
    @user_event_b = authorize UserEvent.find(params[:other_user_event_id])
    if @user_event_a.fingerprint.blank? || @user_event_b.fingerprint.blank?
      raise ActiveRecord::RecordNotFound
    end
    respond_with(@user_event_a, @user_event_b)
  end
end
