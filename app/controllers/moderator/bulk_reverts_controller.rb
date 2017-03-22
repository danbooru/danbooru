module Moderator
  class BulkRevertsController < ApplicationController
    before_filter :moderator_only
    before_filter :init_constraints
    helper PostVersionsHelper
    rescue_from BulkRevert::ConstraintTooGeneralError, :with => :tag_constraint_too_general

    def new
    end

    def create
      @bulk_revert = BulkRevert.new(@constraints)

      if params[:commit] == "Test"
        @bulk_revert.preview
        render action: "new"
      else
        @bulk_revert.delay(:queue => "default").process(@constraints)
        flash[:notice] = "Reverts queued"
        redirect_to new_bulk_revert_path
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
