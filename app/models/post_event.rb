# frozen_string_literal: true

class PostEvent < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :creator, class_name: "User"
  belongs_to :post

  def self.model_types
    %w[Post PostAppeal PostApproval PostDisapproval PostFlag PostReplacement ModAction]
  end

  def self.categories
    # model_types.excluding("ModAction") + ModAction.categories.keys.grep(/\Apost_(?!permanent_delete|vote)/).map(&:camelize)
    %w[Upload Flag Appeal Approval Disapproval Delete Undelete Ban Unban Replacement Regenerate RegenerateIqdb MoveFavorites NoteLockCreate NoteLockDelete RatingLockCreate RatingLockDelete]
  end

  def self.visible(user)
    all
  end

  def self.category_matches(category)
    category = category.squish.titleize.delete(" ")

    case category
    when "Upload"
      where(model_type: "Post")
    when "Flag", "Appeal", "Approval", "Disapproval", "Replacement"
      where(model_type: "Post" + category)
    when *categories
      where(model: ModAction.where(category: "post_" + category.underscore))
    else
      none
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:model, :post, :creator, :event_at], current_user: current_user)

    if params[:category]
      q = q.category_matches(params[:category])
    end

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

  def category
    if model_type == "Post"
      "Upload"
    elsif model_type == "ModAction"
      model.category.camelize.delete_prefix("Post")
    else
      model_type.delete_prefix("Post")
    end
  end

  def pretty_category
    category.titleize.delete_prefix("Post ")
  end

  def readonly?
    true
  end
end
