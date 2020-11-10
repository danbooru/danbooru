require 'digest/sha1'

class Dmail < ApplicationRecord
  validate :validate_sender_is_not_limited, on: :create
  validates_presence_of :title, :body, on: :create

  belongs_to :owner, :class_name => "User"
  belongs_to :to, :class_name => "User"
  belongs_to :from, :class_name => "User"
  has_many :moderation_reports, as: :model, dependent: :destroy

  before_create :autoreport_spam
  after_save :update_unread_dmail_count
  after_destroy :update_unread_dmail_count
  after_commit :send_email, on: :create

  deletable

  scope :read, -> { where(is_read: true) }
  scope :unread, -> { where(is_read: false) }
  scope :sent, -> { where("dmails.owner_id = dmails.from_id") }
  scope :received, -> { where("dmails.owner_id = dmails.to_id") }

  module AddressMethods
    def to_name=(name)
      self.to = User.find_by_name(name)
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
        dmail = Dmail.new(from: User.system, creator_ip_addr: "127.0.0.1", **params)
        dmail.owner = dmail.to
        dmail.save
        dmail
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
    def visible(user)
      where(owner: user)
    end

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

      q = q.search_attributes(params, :is_read, :is_deleted, :title, :body)
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
      id == verifier.verified(key)
    end
  end

  include AddressMethods
  include FactoryMethods
  extend SearchMethods

  def self.mark_all_as_read
    unread.update(is_read: true)
  end

  def quoted_body
    "[quote]\n#{from.pretty_name} said:\n\n#{body}\n[/quote]\n\n"
  end

  def send_email
    if is_recipient? && !is_deleted? && to.receive_email_notifications? && to.can_receive_email?
      UserMailer.dmail_notice(self).deliver_later
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

  def validate_sender_is_not_limited
    return if from.blank? || from.is_gold?

    if from.dmails.where("created_at > ?", 1.hour.ago).group(:to).reorder(nil).count.size >= 10
      errors[:base] << "You can't send dmails to more than 10 users per hour"
    end
  end

  def autoreport_spam
    if is_recipient? && SpamDetector.new(self).spam?
      self.is_deleted = true
      moderation_reports << ModerationReport.new(creator: User.system, reason: "Spam.")
    end
  end

  def update_unread_dmail_count
    return unless saved_change_to_id? || saved_change_to_is_read? || saved_change_to_is_deleted? || destroyed?

    owner.with_lock do
      unread_count = owner.dmails.active.unread.count
      owner.update!(unread_dmail_count: unread_count)
    end
  end

  def dtext_shortlink(key: false, **options)
    key ? "dmail ##{id}/#{self.key}" : "dmail ##{id}"
  end

  def self.searchable_includes
    [:to, :from]
  end

  def self.available_includes
    [:owner, :to, :from]
  end
end
