# frozen_string_literal: true

class Dmail < ApplicationRecord
  attr_accessor :creator_ip_addr

  validate :validate_sender_is_not_limited, on: :create
  validates :title, presence: true, length: { maximum: 200 }, if: :title_changed?
  validates :body, presence: true, length: { maximum: 50_000 }, if: :body_changed?

  belongs_to :owner, :class_name => "User"
  belongs_to :to, :class_name => "User"
  belongs_to :from, :class_name => "User"
  has_many :moderation_reports, as: :model, dependent: :destroy

  before_create :autoreport_spam
  after_destroy :update_unread_dmail_count
  after_save :update_unread_dmail_count
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
        dmail = Dmail.new(from: User.system, **params)
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
      if user.is_anonymous?
        none
      else
        where(owner: user)
      end
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

    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :is_read, :is_deleted, :title, :body, :to, :from], current_user: current_user)
      q = q.where_text_matches([:title, :body], params[:message_matches])

      q = q.folder_matches(params[:folder])

      q.apply_default_order(params)
    end
  end

  concerning :AuthorizationMethods do
    class_methods do
      # XXX hack so that rails' signed_id mechanism works with our pre-existing dmail keys.
      # https://github.com/rails/rails/blob/main/activerecord/lib/active_record/signed_id.rb
      def signed_id_verifier_secret
        Rails.application.key_generator.generate_key("dmail_link")
      end

      def combine_signed_id_purposes(purpose)
        purpose
      end
    end

    def key
      signed_id(purpose: "dmail_link")
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
    if is_recipient? && !is_deleted? && to.receive_email_notifications?
      UserMailer.with(headers: { "X-Danbooru-Dmail": Routes.dmail_url(self) }).dmail_notice(self).deliver_later
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
      errors.add(:base, "You can't send dmails to more than 10 users per hour")
    end
  end

  def autoreport_spam
    if is_recipient? && !is_sender? && SpamDetector.new(self, user_ip: creator_ip_addr).spam?
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

  def self.available_includes
    [:owner, :to, :from]
  end
end
