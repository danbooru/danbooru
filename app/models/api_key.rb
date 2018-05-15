class ApiKey < ApplicationRecord
  belongs_to :user
  validates_uniqueness_of :user_id
  validates_uniqueness_of :key
  has_secure_token :key

  def self.generate!(user)
    create(:user_id => user.id)
  end

  def regenerate!
    regenerate_key
    save
  end
end
