# frozen_string_literal: true

class UserFeedback < ApplicationRecord
  self.table_name = "user_feedback"

  dtext_attribute :body # defines :dtext_body

  attr_accessor :disable_dmail_notification, :updater

  belongs_to :user
  belongs_to :creator, class_name: "User"
  validates :body, visible_string: true
  validates :category, presence: true, inclusion: { in: %w[positive negative neutral] }
  after_create :create_dmail, unless: :disable_dmail_notification
  after_update :create_mod_action

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

    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :category, :body, :is_deleted, :creator, :user], current_user: current_user)

      if params[:hide_bans].to_s.truthy?
        # Feedback generation from bans has changed several times over the years. However they all start like one of the following:
        # "Blocked: "
        # "Banned: "
        # "Banned forever: "
        # "Banned for <duration>: "
        # "Banned <duration>: "
        q = q.where("body ~ '^(?!Banned(:| for| [0-9])|Blocked:)'")
      end

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def user_name=(name)
    self.user = User.find_by_name(name)
  end

  def create_dmail
    body = %{@#{creator.name} created a "#{category} record":#{Routes.user_feedbacks_path(search: { user_id: user_id })} for your account:\n\n#{self.body}}

    if category == "negative"
      body += "\n\n---\n\nA negative feedback is a record on your account that you've engaged in negative or rule-breaking behavior. You can appeal this feedback if you think it's unfair by petitioning the mods and admins in the forum. Negative feedback generally doesn't affect your usability of the site, but serious or repeated infractions may lead to a ban."
    end

    Dmail.create_automated(:to_id => user_id, :title => "Your user record has been updated", :body => body)
  end

  def create_mod_action
    raise "Updater not set" if updater.nil?

    if saved_change_to_is_deleted == [false, true] && creator != updater
      ModAction.log(%{deleted user feedback for "#{user.name}":#{Routes.user_path(user)}}, :user_feedback_delete, subject: user, user: updater)
    elsif creator != updater
      ModAction.log(%{updated user feedback for "#{user.name}":#{Routes.user_path(user)}}, :user_feedback_update, subject: user, user: updater)
    end
  end

  def self.available_includes
    [:creator, :user]
  end
end
