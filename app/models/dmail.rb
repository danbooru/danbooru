require 'digest/sha1'

class Dmail < ApplicationRecord

  validates_presence_of :title, :body, on: :create
  validate :validate_sender_is_not_banned, on: :create

  belongs_to :owner, :class_name => "User"
  belongs_to :to, :class_name => "User"
  belongs_to :from, :class_name => "User"
  has_many :moderation_reports, as: :model

  after_initialize :initialize_attributes, if: :new_record?
  before_create :autoreport_spam
  after_save :update_unread_dmail_count
  after_commit :send_email, on: :create

  api_attributes including: [:key]

  scope :active, -> { where(is_deleted: false) }
  scope :deleted, -> { where(is_deleted: true) }
  scope :read, -> { where(is_read: true) }
  scope :unread, -> { where(is_read: false) }
  scope :visible, -> { where(owner: CurrentUser.user) }
  scope :sent, -> { where("dmails.owner_id = dmails.from_id") }
  scope :received, -> { where("dmails.owner_id = dmails.to_id") }

  module AddressMethods
    def to_name=(name)
      self.to = User.find_by_name(name)
    end

    def initialize_attributes
      self.from_id ||= CurrentUser.id
      self.creator_ip_addr ||= CurrentUser.ip_addr
    end
  end

  module FactoryMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def create_split(params)
        copy = nil

        Dmail.transaction do
          # recipient's copy
          copy = Dmail.new(params)
          copy.owner_id = copy.to_id
          copy.save unless copy.to_id == copy.from_id

          # sender's copy
          copy = Dmail.new(params)
          copy.owner_id = copy.from_id
          copy.is_read = true
          copy.save
        end

        copy
      end

      def create_automated(params)
        CurrentUser.as_system do
          dmail = Dmail.new(from: User.system, **params)
          dmail.owner = dmail.to
          dmail.save
          dmail
        end
      end
    end

    def build_response(options = {})
      Dmail.new do |dmail|
        if title =~ /Re:/
          dmail.title = title
        else
          dmail.title = "Re: #{title}"
        end
        dmail.owner_id = from_id
        dmail.body = quoted_body
        dmail.to_id = from_id unless options[:forward]
        dmail.from_id = to_id
      end
    end
  end

  module SearchMethods
    def sent_by(user)
      where("dmails.from_id = ? AND dmails.owner_id != ?", user.id, user.id)
    end

    def folder_matches(folder)
      case folder
      when "received"
        active.received
      when "unread"
        active.received.unread
      when "sent"
        active.sent
      when "deleted"
        deleted
      else
        all
      end
    end

    def search(params)
      q = super

      q = q.search_attributes(params, :to, :from, :is_read, :is_deleted, :title, :body)
      q = q.text_attribute_matches(:title, params[:title_matches])
      q = q.text_attribute_matches(:body, params[:message_matches], index_column: :message_index)

      q = q.folder_matches(params[:folder])

      q.apply_default_order(params)
    end
  end

  concerning :AuthorizationMethods do
    def verifier
      @verifier ||= Danbooru::MessageVerifier.new(:dmail_link)
    end

    def key
      verifier.generate(id)
    end

    def valid_key?(key)
      decoded_id = verifier.verified(key)
      id == decoded_id
    end

    def visible_to?(user, key)
      owner_id == user.id || valid_key?(key)
    end
  end

  include AddressMethods
  include FactoryMethods
  extend SearchMethods

  def self.mark_all_as_read
    unread.update(is_read: true)
  end

  def validate_sender_is_not_banned
    if from.try(:is_banned?)
      errors[:base] << "Sender is banned and cannot send messages"
    end
  end

  def quoted_body
    "[quote]\n#{from.pretty_name} said:\n\n#{body}\n[/quote]\n\n"
  end

  def send_email
    if is_recipient? && !is_deleted? && to.receive_email_notifications? && to.email =~ /@/
      UserMailer.dmail_notice(self).deliver_now
    end
  end

  def is_automated?
    from == User.system
  end

  def is_sender?
    owner == from
  end

  def is_recipient?
    owner == to
  end

  def autoreport_spam
    if is_recipient? && SpamDetector.new(self).spam?
      self.is_deleted = true
      moderation_reports << ModerationReport.new(creator: User.system, reason: "Spam.")
    end
  end

  def update_unread_dmail_count
    return unless saved_change_to_id? || saved_change_to_is_read? || saved_change_to_is_deleted?

    owner.with_lock do
      unread_count = owner.dmails.active.unread.count
      owner.update!(unread_dmail_count: unread_count)
    end
  end

  def reportable_by?(user)
    owner == user && is_recipient? && !is_automated? && !from.is_moderator?
  end

  def dtext_shortlink(key: false, **options)
    key ? "dmail ##{id}/#{self.key}" : "dmail ##{id}"
  end

  def self.available_includes
    includes_array = [:owner, :to, :from]
    includes_array << :moderation_reports if CurrentUser.is_moderator?
    includes_array
  end
end
