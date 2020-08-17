class PostAppeal < ApplicationRecord
  belongs_to :creator, :class_name => "User"
  belongs_to :post

  validates :reason, length: { maximum: 140 }
  validate :validate_post_is_appealable, on: :create
  validate :validate_creator_is_not_limited, on: :create
  validates :creator, uniqueness: { scope: :post, message: "have already appealed this post" }, on: :create

  enum status: {
    pending: 0,
    succeeded: 1,
    rejected: 2
  }

  scope :expired, -> { pending.where("post_appeals.created_at < ?", Danbooru.config.moderation_period.ago) }

  module SearchMethods
    def search(params)
      q = super
      q = q.search_attributes(params, :reason, :status)
      q = q.text_attribute_matches(:reason, params[:reason_matches])

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def validate_creator_is_not_limited
    errors[:creator] << "have reached your appeal limit" if creator.is_appeal_limited?
  end

  def validate_post_is_appealable
    errors[:post] << "cannot be appealed" if post.is_status_locked? || !post.is_appealable?
  end

  def self.searchable_includes
    [:creator, :post]
  end

  def self.available_includes
    [:creator, :post]
  end
end
