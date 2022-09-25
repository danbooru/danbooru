# frozen_string_literal: true

class PostVote < ApplicationRecord
  attr_accessor :updater

  belongs_to :post
  belongs_to :user
  has_many :mod_actions, as: :subject, dependent: :destroy

  validates :score, inclusion: { in: [1, -1], message: "must be 1 or -1" }

  before_save { post.lock! }
  before_save :update_score_on_delete, if: -> { !new_record? && is_deleted_changed?(from: false, to: true) }
  before_save :update_score_on_undelete, if: -> { !new_record? && is_deleted_changed?(from: true, to: false) }
  before_save :create_mod_action_on_delete_or_undelete
  before_create :update_score_on_create
  before_create :remove_conflicting_votes

  scope :positive, -> { where("post_votes.score > 0") }
  scope :negative, -> { where("post_votes.score < 0") }
  scope :public_votes, -> { active.positive.where.not(user: User.has_private_favorites) }

  deletable

  def self.visible(user)
    if user.is_admin?
      all
    elsif user.is_anonymous?
      public_votes
    else
      active.where(user: user).or(public_votes)
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :score, :is_deleted, :user, :post], current_user: current_user)

    q.apply_default_order(params)
  end

  def is_positive?
    score > 0
  end

  def is_negative?
    score < 0
  end

  def remove_conflicting_votes
    PostVote.active.where.not(id: id).where(post: post, user: user).each do |vote|
      vote.soft_delete!(updater: updater)
    end
  end

  def validate_vote_is_unique
    if !is_deleted? && PostVote.active.where.not(id: id).exists?(post: post, user: user)
      errors.add(:user, "have already voted for this post")
    end
  end

  def update_score_on_create
    if is_positive?
      Post.update_counters(post_id, { score: score, up_score: score })
    else
      Post.update_counters(post_id, { score: score, down_score: score })
    end
  end

  def update_score_on_delete
    if is_positive?
      Post.update_counters(post_id, { score: -score, up_score: -score })
    else
      Post.update_counters(post_id, { score: -score, down_score: -score })
    end
  end

  def update_score_on_undelete
    update_score_on_create
  end

  def create_mod_action_on_delete_or_undelete
    return if new_record? || updater.nil? || updater == user

    if is_deleted_changed?(from: false, to: true)
      ModAction.log("deleted post vote ##{id} on post ##{post_id}", :post_vote_delete, subject: self, user: updater)
    elsif is_deleted_changed?(from: true, to: false)
      ModAction.log("undeleted post vote ##{id} on post ##{post_id}", :post_vote_undelete, subject: self, user: updater)
    end
  end

  def self.available_includes
    [:user, :post]
  end
end
