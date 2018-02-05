class UserFeedback < ApplicationRecord
  self.table_name = "user_feedback"
  belongs_to :user
  belongs_to :creator, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  attr_accessor :disable_dmail_notification
  validates_presence_of :user, :creator, :body, :category
  validates_inclusion_of :category, :in => %w(positive negative neutral)
  validate :creator_is_gold
  validate :user_is_not_creator
  after_create :create_dmail
  after_update(:if => lambda {|rec| CurrentUser.id != rec.creator_id}) do |rec|
    ModAction.log(%{#{CurrentUser.name} updated user feedback for "#{rec.user_name}":/users/#{rec.user_id}},:user_feedback_update)
  end
  after_destroy(:if => lambda {|rec| CurrentUser.id != rec.creator_id}) do |rec|
    ModAction.log(%{#{CurrentUser.name} deleted user feedback for "#{rec.user_name}":/users/#{rec.user_id}},:user_feedback_delete)
  end

  module SearchMethods
    def positive
      where("category = ?", "positive")
    end

    def neutral
      where("category = ?", "neutral")
    end

    def negative
      where("category = ?", "negative")
    end

    def for_user(user_id)
      where("user_id = ?", user_id)
    end

    def visible(viewer = CurrentUser.user)
      if viewer.is_admin?
        all
      else
        # joins(:user).merge(User.undeleted).or(where("body !~ 'Name changed from [^\s:]+ to [^\s:]+'"))
        joins(:user).where.not("users.name ~ 'user_[0-9]+~*' AND user_feedback.body ~ 'Name changed from [^\s:]+ to [^\s:]+'")
      end
    end

    def default_order
      order(created_at: :desc)
    end

    def search(params)
      q = super

      if params[:user_id].present?
        q = q.for_user(params[:user_id].to_i)
      end

      if params[:user_name].present?
        q = q.where("user_id = (select _.id from users _ where lower(_.name) = ?)", params[:user_name].mb_chars.downcase.strip.tr(" ", "_"))
      end

      if params[:creator_id].present?
         q = q.where("creator_id = ?", params[:creator_id].to_i)
      end

      if params[:creator_name].present?
        q = q.where("creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].mb_chars.downcase.strip.tr(" ", "_"))
      end

      if params[:category].present?
        q = q.where("category = ?", params[:category])
      end

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def initialize_creator
    self.creator_id ||= CurrentUser.id
  end

  def user_name
    User.id_to_name(user_id)
  end

  def creator_name
    User.id_to_name(creator_id)
  end

  def user_name=(name)
    self.user_id = User.name_to_id(name)
  end

  def create_dmail
    unless disable_dmail_notification
      body = %{@#{creator_name} created a "#{category} record":/user_feedbacks?search[user_id]=#{user_id} for your account:\n\n#{self.body}}
      Dmail.create_automated(:to_id => user_id, :title => "Your user record has been updated", :body => body)
    end
  end

  def creator_is_gold
    if !creator.is_gold?
      errors[:creator] << "must be gold"
      return false
    else
      return true
    end
  end
  
  def user_is_not_creator
    if user_id == creator_id
      errors[:creator] << "cannot submit feedback for yourself"
      return false
    else
      return true
    end
  end

  def editable_by?(editor)
    (editor.is_moderator? && editor != user) || creator == editor
  end
end
