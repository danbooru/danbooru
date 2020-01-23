class ForumTopicVisitsController < ApplicationController
  respond_to :xml, :json
  before_action :member_only

  def index
    @forum_topic_visits = ForumTopicVisit.where(user: CurrentUser.user).paginated_search(params)
    respond_with(@forum_topic_visits)
  end
end
