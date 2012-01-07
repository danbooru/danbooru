class Dmail < ActiveRecord::Base
  validates_presence_of :to_id
  validates_presence_of :from_id
  validates_format_of :title, :with => /\S/
  validates_format_of :body, :with => /\S/
  before_validation :initialize_from_id, :on => :create
  belongs_to :owner, :class_name => "User"
  belongs_to :to, :class_name => "User"
  belongs_to :from, :class_name => "User"
  after_create :update_recipient
  after_create :send_dmail
  attr_accessible :title, :body, :is_deleted, :to_id, :to, :to_name
  scope :for, lambda {|user| where(["owner_id = ?", user])}
  scope :inbox, where("to_id = owner_id")
  scope :sent, where("from_id = owner_id")
  scope :active, where(["is_deleted = ?", false])
  scope :deleted, where(["is_deleted = ?", true])
  scope :search_message, lambda {|query| where(["message_index @@ plainto_tsquery(?)", query])}
  scope :unread, where("is_read = false and is_deleted = false")
  scope :visible, lambda {where("(to_id = ? or from_id = ?)", CurrentUser.id, CurrentUser.id)}
  
  module AddressMethods
    def to_name
      User.id_to_pretty_name(to_id)
    end

    def from_name
      User.id_to_pretty_name(from_id)
    end

    def to_name=(name)
      user = User.find_by_name(name)
      return if user.nil?
      self.to_id = user.id
    end
    
    def initialize_from_id
      self.from_id = CurrentUser.id
    end
  end
  
  module FactoryMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      def create_split(params)
        copy = nil
        
        Dmail.transaction do
          copy = Dmail.new(params)
          copy.owner_id = copy.to_id
          copy.save!

          copy = Dmail.new(params)
          copy.owner_id = CurrentUser.id
          copy.save!
        end
        
        copy
      end
      
      def new_blank
        Dmail.new do |dmail|
          dmail.from_id = CurrentUser.id
        end
      end
    end
    
    def build_response(options = {})
      Dmail.new do |dmail|
        dmail.title = "Re: #{title}"
        dmail.owner_id = from_id
        dmail.body = quoted_body
        dmail.to_id = from_id unless options[:forward]
        dmail.from_id = to_id
      end
    end
  end
  
  include AddressMethods
  include FactoryMethods
  
  def quoted_body
    "[quote]#{body}[/quote]"
  end
  
  def send_dmail
    if to.receive_email_notifications? && to.email.include?("@")
      UserMailer.dmail_notice(self).deliver
    end    
  end
  
  def mark_as_read!
    update_column(:is_read, true)
    
    unless Dmail.exists?(["to_id = ? AND is_read = false", to_id])
      to.update_column(:has_mail, false)
    end
  end
  
  def update_recipient
    to.update_column(:has_mail, true)
  end
  
  def visible_to?(user)
    user.is_moderator? || owner_id == user.id
  end
end
