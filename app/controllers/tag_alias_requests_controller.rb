class TagAliasRequestsController < ApplicationController
  before_action :member_only

  def new
  end

  def create
    @tag_alias_request = TagAliasRequest.new(tar_params)
    @tag_alias_request.create

    if @tag_alias_request.invalid?
      render :action => "new"
    else
      redirect_to forum_topic_path(@tag_alias_request.forum_topic)
    end
  end

private
  
  def tar_params
    params.require(:tag_alias_request).permit(:antecedent_name, :consequent_name, :reason, :skip_secondary_validations)
  end
end
