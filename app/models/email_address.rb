class EmailAddress < ApplicationRecord
  # https://www.regular-expressions.info/email.html
  EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/

  belongs_to :user, inverse_of: :email_address

  validates :address, presence: true, confirmation: true, format: { with: EMAIL_REGEX }
  validates :normalized_address, uniqueness: true
  validates :user_id, uniqueness: true
  validate :validate_deliverable, on: :deliverable
  after_save :update_user

  def address=(value)
    self.normalized_address = EmailValidator.normalize(value) || address
    super
  end

  def nondisposable?
    EmailValidator.nondisposable?(normalized_address)
  end

  def validate_deliverable
    if EmailValidator.undeliverable?(address)
      errors[:address] << "is invalid or does not exist"
    end
  end

  def update_user
    user.update!(is_verified: is_verified? && nondisposable?)
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
