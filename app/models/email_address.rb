# frozen_string_literal: true

class EmailAddress < ApplicationRecord
  attr_accessor :request, :updater

  attribute :address
  attribute :normalized_address

  belongs_to :user, inverse_of: :email_address

  validates :address, presence: true, format: { message: "is invalid", with: Danbooru::EmailAddress::EMAIL_REGEX, multiline: true }, length: { maximum: 100 }, if: :address_changed?
  validates :normalized_address, presence: true, uniqueness: true
  validates :user_id, uniqueness: true
  validate :validate_deliverable, on: :deliverable

  after_destroy :create_mod_action
  after_save :create_mod_action, if: :saved_change_to_address?
  after_save :update_email_address, if: :saved_change_to_address?

  def self.visible(user)
    if user.is_moderator?
      where(user: User.where("level < ?", user.level).or(User.where(id: user.id)))
    else
      none
    end
  end

  def address=(value)
    value = Danbooru::EmailAddress.correct(value)&.to_s || value
    self.normalized_address = Danbooru::EmailAddress.parse(value)&.canonicalized_address&.to_s || value
    self.is_verified = false
    super
  end

  def is_restricted?
    !Danbooru::EmailAddress.new(normalized_address).is_nondisposable?
  end

  def is_normalized?
    address == normalized_address
  end

  def self.restricted(restricted = true)
    domains = Danbooru::EmailAddress::NONDISPOSABLE_DOMAINS
    domain_regex = domains.map { |domain| Regexp.escape(domain) }.join("|")

    if restricted.to_s.truthy?
      where_not_regex(:normalized_address, "@(#{domain_regex})$")
    elsif restricted.to_s.falsy?
      where_regex(:normalized_address, "@(#{domain_regex})$")
    else
      all
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :user, :address, :normalized_address, :is_verified, :is_deliverable], current_user: current_user)

    q = q.restricted(params[:is_restricted])

    q.apply_default_order(params)
  end

  def validate_deliverable
    if Danbooru::EmailAddress.parse(address)&.undeliverable?
      errors.add(:address, "is invalid or does not exist")
    end
  end

  def verify!
    transaction do
      update!(is_verified: true)

      if user.is_restricted? && !is_restricted?
        user.update!(level: User::Levels::MEMBER, is_verified: is_verified?)
      end
    end
  end

  def update_email_address
    if saved_change_to_address? && !user.previously_new_record?
      UserMailer.with_request(request).email_change_confirmation(user).deliver_later
    end
  end

  def create_mod_action
    return if user.previously_new_record?

    if user == updater
      UserEvent.create_from_request!(user, :email_change, request)
    elsif address_before_last_save.present? && updater.present?
      ModAction.log("changed user ##{user.id}'s email from #{address_before_last_save} to #{address}", :email_address_update, subject: user, user: updater)
    elsif updater.present?
      ModAction.log("changed user ##{user.id}'s email to #{address}", :email_address_update, subject: user, user: updater)
    end
  end

  def verification_key
    signed_id(purpose: "verify")
  end

  def self.available_includes
    [:user]
  end
end
