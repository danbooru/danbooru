class ForumPostVote < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :forum_post
  validates :creator_id, uniqueness: {scope: :forum_post_id}
  validates :score, inclusion: {in: [-1, 0, 1]}

  scope :up, -> {where(score: 1)}
  scope :down, -> {where(score: -1)}
  scope :by, ->(user_id) {where(creator_id: user_id)}
  scope :excluding_user, ->(user_id) {where("creator_id <> ?", user_id)}

  def self.visible(user)
    where(forum_post: ForumPost.visible(user))
  end

  def self.forum_post_matches(params)
    return all if params.blank?
    where(forum_post_id: ForumPost.search(params).reorder(nil).select(:id))
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :score)
    q = q.forum_post_matches(params[:forum_post])
    q.apply_default_order(params)
  end

  def up?
    score == 1
  end

  def down?
    score == -1
  end

  def meh?
    score == 0
  end

  def fa_class
    if score == 1
      return "fa-thumbs-up"
    elsif score == -1
      return "fa-thumbs-down"
    else
      return "fa-meh"
    end
  end

  def vote_type
    if score == 1
      return "up"
    elsif score == -1
      return "down"
    elsif score == 0
      return "meh"
    else
      raise
    end
  end

  def self.searchable_includes
    [:creator, :forum_post]
  end

  def self.available_includes
    [:creator, :forum_post]
  end
end
