require 'digest/sha1'

class Dmail < ActiveRecord::Base
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
  after_create :send_dmail

  module AddressMethods
    def to_name
      User.id_to_pretty_name(to_id)
    end

    def from_name
      User.id_to_pretty_name(from_id)
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
        dmail = Dmail.new(from: Danbooru.config.system_user, **params)
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

  module ApiMethods
    def hidden_attributes
      super + [:message_index]
    end
    
    def method_attributes
      super + [:key]
    end
  end
  
  module SearchMethods
    def active
      where("is_deleted = ?", false)
    end

    def deleted
      where("is_deleted = ?", true)
    end

    def title_matches(query)
      query = "*#{query}*" unless query =~ /\*/
      where("lower(dmails.title) LIKE ?", query.to_escaped_for_sql_like)
    end

    def search_message(query)
      if query =~ /\*/ && CurrentUser.user.is_builder?
        escaped_query = query.to_escaped_for_sql_like
        where("(title ILIKE ? ESCAPE E'\\\\' OR body ILIKE ? ESCAPE E'\\\\')", escaped_query, escaped_query)
      else
        where("message_index @@ plainto_tsquery(?)", query.to_escaped_for_tsquery_split)
      end
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
      q = where("true")
      return q if params.blank?

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

      if params[:read] == "true"
        q = q.where("is_read = true")
      elsif params[:read] == "false"
        q = q.unread
      end

      q
    end
  end

  include AddressMethods
  include FactoryMethods
  include ApiMethods
  extend SearchMethods

  def validate_sender_is_not_banned
    if from.is_banned?
      errors[:base] = "Sender is banned and cannot send messages"
      return false
    else
      return true
    end
  end

  def quoted_body
    "[quote]\n#{from_name} said:\n\n#{body}\n[/quote]\n\n"
  end

  def send_dmail
    if to.receive_email_notifications? && to.email =~ /@/ && owner_id == to.id
      UserMailer.dmail_notice(self).deliver_now
    end
  end

  def mark_as_read!
    update_column(:is_read, true)

    unless Dmail.where(:is_read => false, :owner_id => CurrentUser.user.id).exists?
      CurrentUser.user.update_attribute(:has_mail, false)
    end
  end

  def is_automated?
    from == Danbooru.config.system_user
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
      to.update_attribute(:has_mail, true)
    end
  end
  
  def key
    digest = OpenSSL::Digest.new("sha256")
    OpenSSL::HMAC.hexdigest(digest, Danbooru.config.email_key, "#{title} #{body}")
  end
  
  def visible_to?(user, key)
    owner_id == user.id || (user.is_moderator? && key == self.key)
  end

end
