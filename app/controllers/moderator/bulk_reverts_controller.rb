module Moderator
  class BulkRevertsController < ApplicationController
    before_action :moderator_only
    before_action :init_constraints
    helper PostVersionsHelper
    rescue_from BulkRevert::ConstraintTooGeneralError, :with => :tag_constraint_too_general

    def new
    end

    def create
      @bulk_revert = BulkRevert.new

      if params[:commit] == "Test"
        @bulk_revert.preview
        render action: "new"
      else
        @bulk_revert.delay(:queue => "default", :priority => 15).process(CurrentUser.user, @constraints)
        flash[:notice] = "Reverts queued"
        redirect_to new_moderator_bulk_revert_path
      end
    end

  private

    def init_constraints
      @constraints = params[:constraints] || {}
    end

    def tag_constraint_too_general
      flash[:notice] = "Your tag constraints are too general; try adding min and max version ids"
      render action: "new"
    end
  end
end
