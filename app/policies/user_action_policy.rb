# frozen_string_literal: true

class UserActionPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end

  def can_see_user?
    case record.model_type
    when "Comment"
      policy(record.model).can_see_creator?
    when "PostFlag"
      policy(record.model).can_view_flagger?
    when "PostDisapproval"
      policy(record.model).can_view_creator?
    else
      true
    end
  end
end
