module Moderator
  class TagsController < ApplicationController
    before_filter :moderator_only
    
    def edit
    end
    
    def update
      tag_batch_change = TagBatchChange.new(params[:tag][:predicate], params[:tag][:consequent])
      tag_batch_change.execute
      redirect_to edit_moderator_tag_path, :notice => "Posts updated"
    end
  end
end
