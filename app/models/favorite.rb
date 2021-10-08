class Favorite < ApplicationRecord
  belongs_to :post, counter_cache: :fav_count
  belongs_to :user, counter_cache: :favorite_count

  validates :user_id, uniqueness: { scope: :post_id, message: "have already favorited this post" }
  after_create :upvote_post_on_create
  after_destroy :unvote_post_on_destroy

  scope :public_favorites, -> { where(user: User.bit_prefs_match(:enable_private_favorites, false)) }

  def self.visible(user)
    user.is_admin? ? all : where(user: user).or(public_favorites)
  end

  def self.search(params)
    q = search_attributes(params, :id, :post, :user)
    q.apply_default_order(params)
  end

  def self.available_includes
    [:post, :user]
  end

  def upvote_post_on_create
    if Pundit.policy!(user, PostVote).create?
      PostVote.negative.destroy_by(post: post, user: user)

      # Silently ignore the error if the user has already upvoted the post.
      PostVote.create(post: post, user: user, score: 1)
    end
  end

  def unvote_post_on_destroy
    PostVote.positive.destroy_by(post: post, user: user)
  end
end
