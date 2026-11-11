# frozen_string_literal: true

class ForumTopicVisitPolicy < ApplicationPolicy
  def searchable_attributes
    %i[id created_at updated_at user forum_topic last_read_at]
  end
end
