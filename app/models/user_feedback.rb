class UserFeedback < ApplicationRecord
  self.table_name = "user_feedback"

  belongs_to :user
  belongs_to :creator, class_name: "User"
  attr_accessor :disable_dmail_notification
  validates_presence_of :body, :category
  validates_inclusion_of :category, :in => %w(positive negative neutral)
  after_create :create_dmail, unless: :disable_dmail_notification
  after_update(:if => ->(rec) { CurrentUser.id != rec.creator_id}) do |rec|
    ModAction.log(%{#{CurrentUser.name} updated user feedback for "#{rec.user.name}":/users/#{rec.user_id}}, :user_feedback_update)
  end
  after_destroy(:if => ->(rec) { CurrentUser.id != rec.creator_id}) do |rec|
    ModAction.log(%{#{CurrentUser.name} deleted user feedback for "#{rec.user.name}":/users/#{rec.user_id}}, :user_feedback_delete)
  end

  deletable

  scope :positive, -> { where(category: "positive") }
  scope :neutral,  -> { where(category: "neutral") }
  scope :negative, -> { where(category: "negative") }

  module SearchMethods
    def visible(viewer)
      viewer.is_moderator? ? all : undeleted
    end

    def default_order
      order(created_at: :desc)
    end

    def search(params)
      q = super

      q = q.search_attributes(params, :category, :body, :is_deleted)
      q = q.text_attribute_matches(:body, params[:body_matches])

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def user_name=(name)
    self.user = User.find_by_name(name)
  end

  def disclaimer
    if category != "negative"
      return nil
    end

    "The purpose of feedback is to help you become a valuable member of the site by highlighting adverse behaviors. The author, #{creator.name}, should have sent you a message in the recent past as a warning. The fact that you're receiving this feedback now implies you've ignored their advice.\n\nYou can protest this feedback by petitioning the mods and admins in the forum. If #{creator.name} fails to provide sufficient evidence, you can have the feedback removed. However, if you fail to defend yourself against the accusations, you will likely earn yourself another negative feedback.\n\nNegative feedback generally doesn't affect your usability of the site. But it does mean other users may trust you less and give you less benefit of the doubt.\n\n"
  end

  def create_dmail
    body = %{#{disclaimer}@#{creator.name} created a "#{category} record":/user_feedbacks?search[user_id]=#{user_id} for your account:\n\n#{self.body}}
    Dmail.create_automated(:to_id => user_id, :title => "Your user record has been updated", :body => body)
  end

  def self.searchable_includes
    [:creator, :user]
  end

  def self.available_includes
    [:creator, :user]
  end
end
