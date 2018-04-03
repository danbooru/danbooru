class TagImplicationRequestsController < ApplicationController
  before_action :member_only

  def new
  end

  def create
    @tag_implication_request = TagImplicationRequest.new(tir_params)
    @tag_implication_request.create

    if @tag_implication_request.invalid?
      render :action => "new"
    else
      redirect_to forum_topic_path(@tag_implication_request.forum_topic)
    end
  end

private

  def tir_params
    params.require(:tag_implication_request).permit(:antecedent_name, :consequent_name, :reason, :skip_secondary_validations)
  end
end
