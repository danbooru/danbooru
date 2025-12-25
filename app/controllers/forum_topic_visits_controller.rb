# frozen_string_literal: true

class ForumTopicVisitsController < ApplicationController
  respond_to :xml, :json

  def index
    @forum_topic_visits = authorize ForumTopicVisit.visible(CurrentUser.user).paginated_search(params)
    respond_with(@forum_topic_visits)
  end
end
