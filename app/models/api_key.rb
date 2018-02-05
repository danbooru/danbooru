class ApiKey < ApplicationRecord
  belongs_to :user
  validates_uniqueness_of :user_id
  validates_uniqueness_of :key

  def self.generate!(user)
    create(:user_id => user.id, :key => SecureRandom.urlsafe_base64(32))
  end

  def regenerate!
    update!(:key => SecureRandom.urlsafe_base64(32))
  end
end
