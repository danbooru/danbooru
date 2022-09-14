# frozen_string_literal: true

class Favorite < ApplicationRecord
  belongs_to :post, counter_cache: :fav_count
  belongs_to :user, counter_cache: :favorite_count

  validates :user_id, uniqueness: { scope: :post_id, message: "have already favorited this post" }
  after_create :upvote_post_on_create
  after_destroy :unvote_post_on_destroy

  scope :public_favorites, -> { where.not(user: User.has_private_favorites) }

  def self.visible(user)
    if user.is_admin?
      all
    elsif user.is_anonymous?
      public_favorites
    else
      where(user: user).or(public_favorites)
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :post, :user)
    q.apply_default_order(params)
  end

  def self.available_includes
    [:post, :user]
  end

  def upvote_post_on_create
    if Pundit.policy!(user, PostVote).create? && !PostVote.active.exists?(post: post, user: user, score: 1)
      PostVote.create!(post: post, user: user, score: 1)
    end
  end

  def unvote_post_on_destroy
    vote = PostVote.active.positive.find_by(post: post, user: user)
    vote&.soft_delete!(updater: user)
  end
end
