class TagImplicationsController < ApplicationController
  before_action :admin_only, only: [:destroy]
  respond_to :html, :xml, :json, :js

  def show
    @tag_implication = TagImplication.find(params[:id])
    respond_with(@tag_implication)
  end

  def index
    @tag_implications = TagImplication.paginated_search(params, count_pages: true)
    @tag_implications = @tag_implications.includes(:antecedent_tag, :consequent_tag, :approver) if request.format.html?

    respond_with(@tag_implications)
  end

  def destroy
    @tag_implication = TagImplication.find(params[:id])
    @tag_implication.reject!

    respond_with(@tag_implication, location: tag_implications_path, notice: "Tag implication was deleted")
  end

  private

  def tag_implication_params
    params.require(:tag_implication).permit(%i[antecedent_name consequent_name forum_topic_id skip_secondary_validations])
  end
end
