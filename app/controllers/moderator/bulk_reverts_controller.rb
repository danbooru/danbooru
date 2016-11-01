module Moderator
  class BulkRevertsController < ApplicationController
    before_filter :moderator_only
    helper PostVersionsHelper

    def new
      @constraints = params[:constraints] || {}
    end

    def create
      @constraints = params[:constraints] || {}
      @bulk_revert = BulkRevert.new(@constraints)

      if params[:commit] == "Test"
        @bulk_revert.preview
        render action: "new"
      else
        @bulk_revert.process!
        flash[:notice] = "Reverts queued"
        redirect_to new_bulk_revert_path
      end
    end
  end
end
