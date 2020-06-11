class PostLock < ApplicationRecord
  class Error < StandardError; end

  attr_reader :duration, :edit_level

  ALL_TYPES = %w[status tags rating parent source notes commentary comments pools]
  TYPE_MAPPING = ALL_TYPES.map do |type|
    [
      Hash[type.singularize, type],
      Hash[type.pluralize, type]
    ]
  end.flatten.reduce({}, :merge)
  TYPE_REGEX = TYPE_MAPPING.keys.join("|")
  POST_TYPES = %w[status tags rating parent source]
  POST_QUERY_TYPES = ["all", "none"] + TYPE_MAPPING.keys

  ALL_MAPPING = ALL_TYPES.map do |type|
    Hash[
      type,
      {
        "flags" => "#{type}_lock",
        "changes" => "#{type}_lock_changed"
      }
    ]
  end.reduce({}, :merge)
  ALL_LOCKS = ALL_MAPPING.map { |_k, v| v["flags"] }
  ALL_CHANGES = ALL_MAPPING.map { |_k, v| v["changes"] }

  MIN_LEVELS = {
    Builder: User::Levels::BUILDER,
    Moderator: User::Levels::MODERATOR,
    Admin: User::Levels::ADMIN
  }
  DEFAULT_LEVEL = User::Levels::BUILDER

  DEFAULT_EXPIRATION = 1.week
  MERGE_TIME = 1.hour

  belongs_to :post
  belongs_to :creator, class_name: "User"

  validates :reason, presence: true
  validate :validate_creator_edit_level, on: :create
  validate :validate_locks_or_duration_are_changed, on: :create
  after_initialize :initialize_attributes, if: :new_record?
  before_validation :initialize_bit_changes
  before_save :expire_lock_on_all_removed
  after_commit :invalidate_post_active_lock

  has_bit_flags ALL_LOCKS
  has_bit_flags ALL_CHANGES, :field => "bit_changes"

  scope :unexpired, -> { where("post_locks.expires_at > ?", Time.now.utc) }
  scope :expired, -> { where("post_locks.expires_at <= ?", Time.now.utc) }

  def self.visible(user)
    user.is_builder? ? all : none
  end

  def self.post_last_lock(post_id)
    where(post_id: post_id).unexpired.last
  end

  def self.update_existing_lock?(lock, user = CurrentUser.user)
    lock.present? && lock.created_at > MERGE_TIME.ago && lock.creator_id == user.id
  end

  module SearchMethods
    def search_bit_fields(relation, params, field)
      ALL_MAPPING.each do |_type, value|
        key = value[field]
        if params[key].to_s.truthy?
          relation = relation.send("bit_#{field}_match", key, true)
        elsif params[key].to_s.falsy?
          relation = relation.send("bit_#{field}_match", key, false)
        end
      end

      relation
    end

    def search(params)
      q = super
      q = q.search_attributes(params, :post, :creator, :expires_at, :duration_set, :level_set)
      q = q.text_attribute_matches(:reason, params[:reason_matches])

      q = search_bit_fields(q, params, "flags")
      q = search_bit_fields(q, params, "changes")

      case params[:expires]
      when "active"
        q = q.unexpired
      when "edited"
        q = q.where(expires_at: Time.at(0).utc).where.not(bit_flags: 0)
      when "removed"
        q = q.where(bit_flags: 0)
      when "expired"
        q = q.expired.where.not(expires_at: Time.at(0).utc)
      end

      case params[:order]
      when "expires_at_desc"
        q = q.order("post_locks.expires_at desc")
      when "post_id_desc"
        q = q.order("post_locks.post_id desc")
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  module AssignmentMethods
    def duration=(dur)
      return if dur.blank?

      self.expires_at = dur.to_i.days.from_now
      @duration = dur
      self.duration_set = true
    end

    def edit_level=(level)
      return if level.blank?

      previous_level = edited_lock&.min_level || DEFAULT_LEVEL
      if level.to_i != previous_level
        @edit_level = self.min_level = level
        self.level_set = true
      else
        @edit_level = self.min_level = previous_level
        self.level_set = false
      end
    end
  end

  module ValidationMethods
    def validate_creator_edit_level
      raise User::PrivilegeError if present_lock.present? && present_lock.min_level > creator.level
    end

    def validate_locks_or_duration_are_changed
      return unless bit_changes.zero?

      if bit_flags.zero?
        errors[:input] << "must add at least one lock"
      elsif !duration_set && !level_set
        message = "must change at least one lock"
        message += ", the duration, or the edit level" if CurrentUser.is_moderator?
        errors[:input] << message
      end
    end
  end

  module InitializeMethods
    def initialize_attributes
      self.creator_id ||= CurrentUser.id
      self.min_level ||= present_lock&.min_level || DEFAULT_LEVEL

      return if duration_set
      # If current lock expires more than a week from now (set by a moderator)
      self.expires_at = present_lock&.expires_at&.send(">", DEFAULT_EXPIRATION.from_now) ? present_lock.expires_at : DEFAULT_EXPIRATION.from_now
    end

    # Done separately since factory tests create blank entries before assigning variables
    # so the initialize attributes function never sees the bit_flags set
    def initialize_bit_changes
      self.bit_changes = bit_flags
      self.bit_changes ^= last_lock.bit_flags if last_lock.present?
    end

    def expire_lock_on_all_removed
      return unless bit_flags.zero?

      self.expires_at = Time.at(0).utc
    end

    def invalidate_post_active_lock
      post.invalidate_active_lock
    end
  end

  module CreateUpdateMethods
    def carryover_locks(attributes)
      new_lock = self.class.new(creator: CurrentUser.user, post_id: post_id, bit_flags: bit_flags)
      new_lock.attributes = attributes
      new_lock.save
      new_lock.expire_other_active_post_locks
      new_lock
    end

    def update_locks(attributes)
      test_lock = dup
      test_lock.attributes = attributes
      bits_change = test_lock.bit_flags ^ bit_flags
      self.attributes = attributes
      self.bit_changes ^= bits_change
      save
      expire_other_active_post_locks
      self
    end
  end

  module PostMethods
    def other_post_locks
      return [] if post_id.nil?

      @other_post_locks ||= begin
        post.locks.where.not(id: id).order("id desc").to_a
      end
    end

    def other_active_post_locks
      other_post_locks.reject { |lock| lock.expires_at < Time.now.utc }
    end

    def previous_lock
      other_post_locks[0]
    end

    def edited_lock
      previous_lock if previous_lock.present? && previous_lock.was_edited?
    end

    def present_lock
      previous_lock unless previous_lock.blank? || previous_lock.expired?
    end

    def last_lock
      present_lock || edited_lock
    end

    def expire_other_active_post_locks
      return unless errors.empty?

      other_active_post_locks.each do |lock|
        lock.expires_at = Time.at(0).utc
        lock.save
      end
    end
  end

  module BooleanMethods
    def was_edited?
      expires_at == Time.at(0).utc && bit_flags.positive?
    end

    def expired?
      expires_at < Time.now.utc
    end

    def editable_by?(user = CurrentUser.user)
      user.level >= min_level
    end
  end

  extend SearchMethods
  include AssignmentMethods
  include ValidationMethods
  include InitializeMethods
  include CreateUpdateMethods
  include PostMethods
  include BooleanMethods

  def self.available_includes
    [:creator, :post]
  end
end
