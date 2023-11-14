# frozen_string_literal: true

class PostEventPolicy < ApplicationPolicy
  def can_see_creator?
    case event.model_type
    when "PostFlag"
      policy(event.model).can_view_flagger?
    when "PostDisapproval"
      policy(event.model).can_view_creator?
    else
      true
    end
  end

  def api_attributes
    [:model_type, :model_id, :post_id, (:creator_id if can_see_creator?), :event_at].compact
  end

  def visible_for_search(events, attribute)
    case attribute
    in :creator | :creator_id
      events.model_types.map do |type|
        attr = attribute
        attr = attr.to_s.gsub("creator", "uploader").to_sym if type == "Post"
        attr = attr.to_s.gsub("creator", "user").to_sym if type in "PostApproval" | "PostDisapproval"

        if type == "ModAction"
          # XXX don't apply visible_for_search to mod actions because it's slow and we know all mod actions are visible
          events.where(model_type: "ModAction")
        else
          # XXX ordering by created_at desc is a query planner hack to make Postgres use the right indexes.
          events.where(model: type.constantize.visible_for_search(attr, user).order(created_at: :desc))
        end
      end.reduce(:or)
    else
      events
    end
  end

  alias_method :event, :record
end
