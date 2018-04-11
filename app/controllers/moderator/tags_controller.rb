module Moderator
  class TagsController < ApplicationController
    before_action :moderator_only
    rescue_from TagBatchChange::Error, :with => :error

    def edit
    end

    def update
      Delayed::Job.enqueue(TagBatchChange.new(params[:tag][:antecedent], params[:tag][:consequent], CurrentUser.user.id, CurrentUser.ip_addr), :queue => "default")
      redirect_to edit_moderator_tag_path, :notice => "Post changes queued"
    end

    def error
      redirect_to edit_moderator_tag_path, :notice => "Error"
    end
  end
end
