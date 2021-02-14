class ApiKey < ApplicationRecord
  belongs_to :user
  validates_uniqueness_of :user_id
  validates_uniqueness_of :key
  has_secure_token :key

  def self.visible(user)
    if user.is_owner?
      all
    else
      where(user: user)
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :key, :user)
    q = q.apply_default_order(params)
    q
  end
end
