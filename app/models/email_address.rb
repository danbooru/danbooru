class EmailAddress < ApplicationRecord
  belongs_to :user, inverse_of: :email_address

  validates :address, presence: true, confirmation: true, format: { with: EmailValidator::EMAIL_REGEX }
  validates :normalized_address, uniqueness: true
  validates :user_id, uniqueness: true
  validate :validate_deliverable, on: :deliverable
  after_save :update_user

  def self.visible(user)
    if user.is_moderator?
      where(user: User.where("level < ?", user.level).or(User.where(id: user.id)))
    else
      none
    end
  end

  def address=(value)
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
    domains = Danbooru.config.email_domain_verification_list
    domain_regex = domains.map { |domain| Regexp.escape(domain) }.join("|")

    if restricted.to_s.truthy?
      where_not_regex(:normalized_address, "@(#{domain_regex})$")
    elsif restricted.to_s.falsy?
      where_regex(:normalized_address, "@(#{domain_regex})$")
    else
      all
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :user, :address, :normalized_address, :is_verified, :is_deliverable)

    q = q.restricted(params[:is_restricted])
    q = q.apply_default_order(params)

    q
  end

  def validate_deliverable
    if EmailValidator.undeliverable?(address)
      errors.add(:address, "is invalid or does not exist")
    end
  end

  def update_user
    user.update!(is_verified: is_verified? && !is_restricted?)
  end

  concerning :VerificationMethods do
    def verifier
      @verifier ||= Danbooru::MessageVerifier.new(:email_verification_key)
    end

    def verification_key
      verifier.generate(id)
    end

    def valid_key?(key)
      id == verifier.verified(key)
    end
  end
end
