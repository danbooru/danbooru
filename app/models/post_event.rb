# frozen_string_literal: true

class PostEvent < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :creator, class_name: "User"
  belongs_to :post

  def self.model_types
    %w[Post PostAppeal PostApproval PostDisapproval PostFlag PostReplacement]
  end

  def self.visible(user)
    all
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:model, :post, :creator, :event_at], current_user: current_user)

    case params[:order]
    when "event_at_asc"
      q = q.order(event_at: :asc, model_id: :asc)
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def self.default_order
    order(event_at: :desc, model_id: :desc)
  end

  def self.available_includes
    [:post, :model] # XXX creator isn't included because it leaks flagger/disapprover names
  end

  def readonly?
    true
  end
end
