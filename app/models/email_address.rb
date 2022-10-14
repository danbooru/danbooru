# frozen_string_literal: true

class EmailAddress < ApplicationRecord
  belongs_to :user, inverse_of: :email_address

  attribute :address
  attribute :normalized_address

  validates :address, presence: true, format: { message: "is invalid", with: EmailValidator::EMAIL_REGEX }
  validates :normalized_address, presence: true, uniqueness: true
  validates :user_id, uniqueness: true
  validate :validate_deliverable, on: :deliverable

  def self.visible(user)
    if user.is_moderator?
      where(user: User.where("level < ?", user.level).or(User.where(id: user.id)))
    else
      none
    end
  end

  def address=(value)
    value = Danbooru::EmailAddress.normalize(value)&.to_s || value
    self.normalized_address = EmailValidator.normalize(value) || address
    super
  end

  def is_restricted?
    EmailValidator.is_restricted?(normalized_address)
  end

  def is_normalized?
    address == normalized_address
  end

  def is_valid?
    EmailValidator.is_valid?(address)
  end

  def self.restricted(restricted = true)
    domains = EmailValidator::NONDISPOSABLE_DOMAINS
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
    if EmailValidator.undeliverable?(address)
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

  def verification_key
    signed_id(purpose: "verify")
  end

  def self.available_includes
    [:user]
  end
end
