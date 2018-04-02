module Moderator
  class InvitationsController < ApplicationController
    before_action :moderator_only

    def new
    end

    def create
      User.find(params[:invitation][:user_id]).invite!(params[:invitation][:level], params[:invitation][:can_upload_free])
      redirect_to moderator_invitations_path
    end

    def index
      @users = User.where("inviter_id = ?", CurrentUser.id).paginate(params[:page])
    end
  end
end
