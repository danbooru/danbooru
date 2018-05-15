require 'digest/sha1'

class Dmail < ApplicationRecord
  # if a person sends spam to more than 10 users within a 24 hour window, automatically ban them for 3 days.
  AUTOBAN_THRESHOLD = 10
  AUTOBAN_WINDOW = 24.hours
  AUTOBAN_DURATION = 3

  include Rakismet::Model

  with_options on: :create do
    validates_presence_of :to_id
    validates_presence_of :from_id
    validates_format_of :title, :with => /\S/
    validates_format_of :body, :with => /\S/
    validate :validate_sender_is_not_banned
  end

  belongs_to :owner, :class_name => "User"
  belongs_to :to, :class_name => "User"
  belongs_to :from, :class_name => "User"

  after_initialize :initialize_attributes, if: :new_record?
  before_create :auto_read_if_filtered
  after_create :update_recipient
  after_commit :send_email, on: :create

  rakismet_attrs author: :from_name, author_email: :from_email, content: :title_and_body, user_ip: :creator_ip_addr_str

  concerning :SpamMethods do
    class_methods do
      def is_spammer?(user)
        return false if user.is_gold?

        spammed_users = sent_by(user).where(is_spam: true).where("created_at > ?", AUTOBAN_WINDOW.ago).distinct.count(:to_id)
        spammed_users >= AUTOBAN_THRESHOLD
      end

      def ban_spammer(spammer)
        spammer.bans.create! do |ban|
          ban.banner = User.system
          ban.reason = "Spambot."
          ban.duration = AUTOBAN_DURATION
        end
      end
    end

    def title_and_body
      "#{title}\n\n#{body}"
    end

    def creator_ip_addr_str
      creator_ip_addr.to_s
    end

    def spam?
      return false if Danbooru.config.rakismet_key.blank?
      return false if from.is_gold?
      super()
    end
  end

  module AddressMethods
    def to_name
      User.id_to_pretty_name(to_id)
    end

    def from_name
      User.id_to_pretty_name(from_id)
    end

    def from_email
      from.email
    end

    def to_name=(name)
      self.to_id = User.name_to_id(name)
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
          copy.is_spam = copy.spam?
          copy.save unless copy.to_id == copy.from_id

          # sender's copy
          copy = Dmail.new(params)
          copy.owner_id = copy.from_id
          copy.is_read = true
          copy.save

          Dmail.ban_spammer(copy.from) if Dmail.is_spammer?(copy.from)
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

  module ApiMethods
    def hidden_attributes
      super + [:message_index]
    end
    
    def method_attributes
      super + [:key]
    end
  end
  
  module SearchMethods
    def sent_by(user)
      where("dmails.from_id = ? AND dmails.owner_id != ?", user.id, user.id)
    end

    def active
      where("is_deleted = ?", false)
    end

    def deleted
      where("is_deleted = ?", true)
    end

    def title_matches(query)
      query = "*#{query}*" unless query =~ /\*/
      where("lower(dmails.title) LIKE ?", query.mb_chars.downcase.to_escaped_for_sql_like)
    end

    def search_message(query)
      if query =~ /\*/ && CurrentUser.user.is_builder?
        escaped_query = query.to_escaped_for_sql_like
        where("(title ILIKE ? ESCAPE E'\\\\' OR body ILIKE ? ESCAPE E'\\\\')", escaped_query, escaped_query)
      else
        where("message_index @@ plainto_tsquery(?)", query.to_escaped_for_tsquery_split)
      end
    end

    def read
      where(is_read: true)
    end

    def unread
      where("is_read = false and is_deleted = false")
    end

    def visible
      where("owner_id = ?", CurrentUser.id)
    end

    def to_name_matches(name)
      where("to_id = (select _.id from users _ where lower(_.name) = ?)", name.mb_chars.downcase)
    end

    def from_name_matches(name)
      where("from_id = (select _.id from users _ where lower(_.name) = ?)", name.mb_chars.downcase)
    end

    def search(params)
      q = super

      if params[:title_matches].present?
        q = q.title_matches(params[:title_matches])
      end

      if params[:message_matches].present?
        q = q.search_message(params[:message_matches])
      end

      if params[:to_name].present?
        q = q.to_name_matches(params[:to_name])
      end

      if params[:to_id].present?
        q = q.where("to_id = ?", params[:to_id].to_i)
      end

      if params[:from_name].present?
        q = q.from_name_matches(params[:from_name])
      end

      if params[:from_id].present?
        q = q.where("from_id = ?", params[:from_id].to_i)
      end

      params[:is_spam] = false unless params[:is_spam].present?
      q = q.attribute_matches(:is_spam, params[:is_spam])
      q = q.attribute_matches(:is_read, params[:is_read])
      q = q.attribute_matches(:is_deleted, params[:is_deleted])

      q = q.read if params[:read].to_s.truthy?
      q = q.unread if params[:read].to_s.falsy?

      q.apply_default_order(params)
    end
  end

  include AddressMethods
  include FactoryMethods
  include ApiMethods
  extend SearchMethods

  def validate_sender_is_not_banned
    if from.is_banned?
      errors[:base] << "Sender is banned and cannot send messages"
      return false
    else
      return true
    end
  end

  def quoted_body
    "[quote]\n#{from_name} said:\n\n#{body}\n[/quote]\n\n"
  end

  def send_email
    if !is_spam? && to.receive_email_notifications? && to.email =~ /@/ && owner_id == to.id
      UserMailer.dmail_notice(self).deliver_now
    end
  end

  def mark_as_read!
    update_column(:is_read, true)
    owner.dmails.unread.count.tap do |unread_count|
      owner.update(has_mail: (unread_count > 0), unread_dmail_count: unread_count)
    end
  end

  def is_automated?
    from == User.system
  end

  def filtered?
    CurrentUser.dmail_filter.try(:filtered?, self)
  end

  def auto_read_if_filtered
    if owner_id != CurrentUser.id && to.dmail_filter.try(:filtered?, self)
      self.is_read = true
    end
  end

  def update_recipient
    if owner_id != CurrentUser.user.id && !is_deleted? && !is_read?
      to.update(has_mail: true, unread_dmail_count: to.dmails.unread.count)
    end
  end
  
  def key
    verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.email_key, serializer: JSON, digest: "SHA256")
    verifier.generate("#{title} #{body}")
  end
  
  def visible_to?(user, key)
    owner_id == user.id || (user.is_moderator? && key == self.key)
  end
end
