class EmailAddress < ApplicationRecord
  # https://www.regular-expressions.info/email.html
  EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/

  belongs_to :user

  validates :address, presence: true, confirmation: true, format: { with: EMAIL_REGEX }
  validates :normalized_address, uniqueness: true
  validates :user_id, uniqueness: true

  def address=(value)
    self.normalized_address = EmailNormalizer.normalize(value) || address
    super
  end
end
