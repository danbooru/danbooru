# frozen_string_literal: true

# Stores credentials used by extractors (usernames, passwords, cookies, API keys, etc) in the database.
class SiteCredential < ApplicationRecord
  SITES = [
    # id, site, defaults
    [100, "ArtStreet", { session_cookie: Danbooru.config.art_street_session_cookie }],
    [200, "Baraag", { access_token: Danbooru.config.baraag_access_token }],
    [300, "Behance", { session_cookie: Danbooru.config.behance_session_cookie }],
    [400, "Blogger", { api_key: Danbooru.config.blogger_api_key }],
    [500, "Bluesky", { identifier: Danbooru.config.bluesky_identifier, password: Danbooru.config.bluesky_password }],
    [600, "CiEn", { session_cookie: Danbooru.config.ci_en_session_cookie }],
    [700, "Cohost", { session_cookie: Danbooru.config.cohost_session_cookie }],
    [800, "DeviantArt", { client_id: Danbooru.config.deviantart_client_id, client_secret: Danbooru.config.deviantart_client_secret }],
    [900, "Fantia", { session_id: Danbooru.config.fantia_session_id }],
    [1000, "Furaffinity", { cookie_a: Danbooru.config.furaffinity_cookie_a, cookie_b: Danbooru.config.furaffinity_cookie_b }],
    [1100, "Inkbunny", { username: Danbooru.config.inkbunny_username, password: Danbooru.config.inkbunny_password }],
    [1200, "Newgrounds", { session_cookie: Danbooru.config.newgrounds_session_cookie }],
    [1300, "NicoSeiga", { user_session: Danbooru.config.nico_seiga_user_session }],
    [1400, "Nijie", { login: Danbooru.config.nijie_login, password: Danbooru.config.nijie_password }],
    [1500, "Pawoo", { access_token: Danbooru.config.pawoo_access_token }],
    [1600, "Piapro", { session_cookie: Danbooru.config.piapro_session_cookie }],
    [1700, "Pixiv", { phpsessid: Danbooru.config.pixiv_phpsessid }],
    [1800, "Poipiku", { session_cookie: Danbooru.config.poipiku_session_cookie }],
    [1900, "Postype", { session_cookie: Danbooru.config.postype_session_cookie }],
    [2000, "Plurk", { session_cookie: Danbooru.config.plurk_session_cookie }],
    [2100, "Tinami", { session_id: Danbooru.config.tinami_session_id }],
    [2200, "Tumblr", { consumer_key: Danbooru.config.tumblr_consumer_key }],
    [2300, "Twitter", { auth_token: Danbooru.config.twitter_auth_token, csrf_token: Danbooru.config.twitter_csrf_token }],
    [2400, "Xfolio", { session_cookie: Danbooru.config.xfolio_session }],
    [2500, "Zerochan", { user_id: Danbooru.config.zerochan_user_id, session_cookie: Danbooru.config.zerochan_session_cookie }],
  ]

  # @return [Hash<String, SiteCredential>] The set of default credentials for each site. Default credentials come from
  #   the environment or from the danbooru_local_config.rb file.
  DEFAULT_CREDENTIALS = SITES.filter_map do |_id, site, credential|
    next if credential.values.any?(&:blank?)
    [site, credential]
  end.to_h.with_indifferent_access

  enum :site, SITES.to_h { |id, site, _credentials| [site, id] }, scopes: false, instance_methods: false

  enum :status, {
    unknown: 0,        # The credential hasn't been used yet, or failed for an unknown reason.
    valid: 100,        # The credential works and can be used.
    invalid: 200,      # The password or API key is incorrect.
    expired: 300,      # The cookie or API key is expired.
    rate_limited: 400, # The account is rate-limited.
    banned: 500,       # The account has been banned.
  }, prefix: "is", validate: true

  belongs_to :creator, class_name: "User"
  validates :site, presence: true, inclusion: { in: sites.keys, allow_nil: true }
  normalizes :credential, with: ->(credential) { credential.is_a?(Hash) ? credential : credential.to_s.parse_json.try(:to_h) }
  validates :credential, presence: true

  scope :enabled, -> { where(is_enabled: true) }
  scope :disabled, -> { where(is_enabled: false) }
  scope :is_public, -> { where(is_public: true) }
  scope :personal, -> { where(is_public: false) }

  def self.visible(user)
    if user.is_admin?
      where(creator: user).or(is_public)
    else
      where(creator: user)
    end
  end

  # Get all the credentials available for a given site. Credentials are taken from the environment, the danbooru_local_config.rb
  # file, and the database, in that order.
  #
  # @param site [String] The site to get credentials for.
  # @param default_credentials [Hash<String, String>] If present, these credentials are used instead of ones from the database.
  # @return [Array<SiteCredential>] The credentials for the given site. May be an empty array if none are configured or enabled.
  #   If default credentials are returned, they're read only so they can't be modified or saved to the database.
  def self.for_site(site, default_credentials: DEFAULT_CREDENTIALS[site])
    if default_credentials.present?
      credential = SiteCredential.new(site: site, credential: default_credentials).freeze.tap(&:readonly!)
      [credential]
    else
      is_public.enabled.where(site: site).order(last_used_at: :asc)
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :creator, :is_enabled, :is_public, :status, :usage_count, :error_count, :last_used_at, :last_error_at, :credential, :metadata], current_user: current_user)
    q.apply_default_order(params)
  end

  # Should be called each time the credential is successfully used.
  def success!(**metadata)
    return if readonly?

    with_lock do
      increment(:usage_count)
      self.metadata.deep_merge!(metadata)
      update!(last_used_at: Time.zone.now, status: :valid)
    end
  end

  # Should be called each time the credential fails. Should only be used for errors caused by the credential itself not
  # working (such as being banned or rate limited), not for errors caused by posts being deleted or inaccessible to the
  # user (such as being followers-only, etc).
  #
  # @param status [Symbol] The reason the credential failed. Can be :invalid, :expired, :banned, :rate_limited, or :unknown.
  def error!(status = :unknown, **metadata)
    return if readonly?

    with_lock do
      increment(:usage_count)
      increment(:error_count)
      self.metadata.deep_merge!(metadata)
      update!(last_used_at: Time.zone.now, last_error_at: Time.zone.now, status: status)
    end
  end
end
