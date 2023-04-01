# frozen_string_literal: true

class Reaction < ApplicationRecord
  MODEL_TYPES = %w[Post Comment ForumPost]

  REACTIONS = Danbooru.config.reactions

  belongs_to :model, polymorphic: true
  belongs_to :creator, class_name: "User"

  validates :creator, uniqueness: { scope: [:model_type, :model_id, :creator_id, :reaction_id], message: ->(reaction, data) { "already used this reaction." } }, on: :create
  validates :model_type, inclusion: { in: MODEL_TYPES }

  scope :post, -> { where(model_type: "Post") }
  scope :comment, -> { where(model_type: "Comment") }
  scope :forum_post, -> { where(model_type: "ForumPost") }

  def self.visible(user)
    all
  end

  def self.model_types
    MODEL_TYPES
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :creator, :model, :reaction_id], current_user: current_user)
    q.apply_default_order(params)
  end

  def self.available_includes
    [:creator, :model]
  end
end
