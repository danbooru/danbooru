class LinkedAccount < ApplicationRecord
  belongs_to :user
  enum site: {
    "DeviantArt": 100,
    "Discord": 200,
  }

  scope :is_public, -> { where(is_public: true) }
  scope :is_private, -> { where(is_public: false) }

  def self.visible(user)
    if user.is_admin?
      all
    else
      where(user: user).or(is_public)
    end
  end

  def self.search(params = {})
    q = super
    q = q.search_attributes(params, :user, :account_id, :is_public, :account_data_updated_at, :api_key_updated_at)
    q = q.apply_default_order(params)
    q
  end

  def self.link_account!(user:, code:, state:)
    oauth2_client = Oauth2Client.from_state!(state, user)
    access_token = oauth2_client.access_token(code)

    linked_account = LinkedAccount.new(user: user, site: oauth2_client.site, api_key: access_token)
    linked_account.fetch_account_data(oauth2_client.http)
    linked_account.tap(&:save!)
  end

  def self.api_attributes
    super - [:api_key, :account_data, :api_key_updated_at, :account_data_updated_at]
  end

  def user_name
    case site
    when "Discord"
      "#{account_data["username"]}##{account_data["discriminator"]}"
    when "DeviantArt"
      account_data["username"]
    end
  end

  def profile_url
    case site
    when "Discord"
      nil
    when "DeviantArt"
      "https://www.deviantart.com/#{user_name}"
    end
  end

  def site_url
    case site
    when "Discord"
      "https://discord.com"
    when "DeviantArt"
      "https://www.deviantart.com"
    end
  end

  def fetch_account_data(http)
    case site
    when "Discord"
      response = http.headers(Authorization: "Bearer #{api_key["access_token"]}").get("https://discord.com/api/users/@me")
      self.account_data = response.parse
      self.account_id = account_data["id"]
    when "DeviantArt"
      response = http.headers(Authorization: "Bearer #{api_key["access_token"]}").get("https://www.deviantart.com/api/v1/oauth2/user/whoami?expand=user.details,user.geo,user.profile,user.stats")
      self.account_data = response.parse
      self.account_id = account_data["userid"]
    end
  end

  def authorization_url(redirect_uri:)
    Oauth2Client.new(site, redirect_uri: redirect_uri).authorization_url(user: user)
  end

  def api_key=(api_key)
    super(api_key)
    self.api_key_updated_at = Time.zone.now if api_key_changed?
  end

  def account_data=(account_data)
    super(account_data)
    self.account_data_updated_at = Time.zone.now if account_data_changed?
  end
end
