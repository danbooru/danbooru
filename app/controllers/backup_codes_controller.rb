# frozen_string_literal: true

class BackupCodesController < ApplicationController
  respond_to :html, :xml, :json

  before_action :requires_reauthentication, only: [:index, :create]
  rate_limit :create, rate: 1.0/1.minute, burst: 10

  def index
    @user = authorize User.find(params[:user_id]), policy_class: BackupCodePolicy
    @user.generate_backup_codes!(request) if @user.backup_codes.blank?
    @url = params[:url]

    respond_with(@user)
  end

  def create
    @user = authorize User.find(params[:user_id]), policy_class: BackupCodePolicy
    @user.generate_backup_codes!(request)

    flash[:notice] = "Backup codes regenerated"
    respond_with(@user, location: user_backup_codes_path(@user))
  end
end
