# frozen_string_literal: true

class BackupCodesController < ApplicationController
  respond_to :text, :html, :xml, :json

  before_action :requires_reauthentication, only: [:index, :create, :recover, :confirm_recover]

  def index
    @user = authorize User.find(params[:user_id]), policy_class: BackupCodePolicy
    @user.generate_backup_codes!(request) if @user.backup_codes.blank?
    @url = params[:url]

    respond_with(@user)
  end

  def create
    @user = authorize User.find(params[:user_id]), policy_class: BackupCodePolicy
    @user.generate_backup_codes!(request)

    respond_with(@user, notice: "Backup codes regenerated", location: user_backup_codes_path(@user))
  end

  def confirm_recover
    @user = authorize User.find(params[:user_id]), policy_class: BackupCodePolicy

    respond_with(@user)
  end

  def recover
    @user = authorize User.find(params[:user_id]), policy_class: BackupCodePolicy
    @user.send_backup_code!(CurrentUser.user)

    respond_with(@user, notice: "Backup code sent", location: edit_admin_user_path(@user))
  end
end
