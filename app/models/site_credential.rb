# frozen_string_literal: true

# Stores credentials used by extractors (usernames, passwords, cookies, API keys, etc) in the database.
class SiteCredential < ApplicationRecord
  SITES = [
    {
      id: 100,
      name: "ArtStreet",
      default_credential: { session_cookie: Danbooru.config.art_street_session_cookie },
      help: %{Your "ArtStreet":https://medibang.com 'MSID' cookie. Go to your profile settings and set your age to 18+ to view R-18 works.},
    }, {
      id: 200,
      name: "Baraag",
      default_credential: { access_token: Danbooru.config.baraag_access_token },
      help: %{Your "Baraag":https://baraag.net access token. Go to "Preferences > Development":[https://baraag.net/settings/applications], create a new application with the 'read' scope, and copy the access token.},
    }, {
      id: 300,
      name: "Behance",
      default_credential: { session_cookie: Danbooru.config.behance_session_cookie },
      help: %{Your "Behance":https://www.behance.net 'iat0' cookie.},
    }, {
      id: 400,
      name: "Blogger",
      default_credential: { api_key: Danbooru.config.blogger_api_key },
      help: %{Your "Blogger":https://blogger.com API key. Go to https://developers.google.com/blogger/docs/3.0/using#APIKey to create an API key.},
    },
    # { id: 500, name: "Bluesky" }, # we now use a loginless method
    {
      id: 600,
      name: "Ci-En",
      default_credential: { session_cookie: Danbooru.config.ci_en_session_cookie },
      help: %{Your "Ci-En":https://ci-en.net 'ci_en_session' cookie.},
    },
    # { id: 700, name: "Cohost" }, # site was shut down
    {
      id: 800,
      name: "Deviant Art",
      default_credential: { client_id: Danbooru.config.deviantart_client_id, client_secret: Danbooru.config.deviantart_client_secret },
      help: %{Your "DeviantArt":https://www.deviantart.com client ID and client secret. Go to https://www.deviantart.com/developers/ to create a new application.},
    }, {
      id: 900,
      name: "Fantia",
      default_credential: { session_id: Danbooru.config.fantia_session_id },
      help: %{Your "Fantia":https://fantia.jp '_session_id' cookie.},
    }, {
      id: 1000,
      name: "Furaffinity",
      default_credential: { cookie_a: Danbooru.config.furaffinity_cookie_a, cookie_b: Danbooru.config.furaffinity_cookie_b },
      help: %{Your "Furaffinity":https://www.furaffinity.net 'cookie_a' and 'cookie_b' cookies. Warning: logging out of Furaffinity will invalidate these cookies.},
    }, {
      id: 1050,
      name: "Gelbooru",
      default_credential: { user_id: Danbooru.config.gelbooru_user_id, api_key: Danbooru.config.gelbooru_api_key },
      help: %{Your "Gelbooru":https://gelbooru.com user ID and API key. Go to https://gelbooru.com/index.php?page=account&s=options to find your API key.},
    }, {
      id: 1060,
      name: "Huashijie",
      default_credential: { user_id: Danbooru.config.huashijie_user_id, session_cookie: Danbooru.config.huashijie_session_cookie },
      help: %{Your "Huashijie":https://www.huashijie.art 'userId' and 'token' cookies.},
    }, {
      id: 1100,
      name: "Inkbunny",
      default_credential: { username: Danbooru.config.inkbunny_username, password: Danbooru.config.inkbunny_password },
      help: %{Your "Inkbunny":https://inkbunny.net username and password. Go to https://inkbunny.net/account.php and enable API access, then go to https://inkbunny.net/userrate.php and enable all ratings.},
    }, {
      id: 1200,
      name: "Newgrounds",
      default_credential: { session_cookie: Danbooru.config.newgrounds_session_cookie },
      help: %{Your "Newgrounds":https://www.newgrounds.com 'vmkIdu5l8m' cookie.},
    }, {
      id: 1300,
      name: "Nico Seiga",
      default_credential: { user_session: Danbooru.config.nico_seiga_user_session },
      help: %{Your "NicoSeiga":https://seiga.nicovideo.jp 'user_session' cookie.},
    }, {
      id: 1400,
      name: "Nijie",
      default_credential: { login: Danbooru.config.nijie_login, password: Danbooru.config.nijie_password },
      help: %{Your "Nijie":https://nijie.info login and password.},
    }, {
      id: 1500,
      name: "Pawoo",
      default_credential: { access_token: Danbooru.config.pawoo_access_token },
      help: %{Your "Pawoo":https://pawoo.net access token. Go to "Preferences > Development":[https://pawoo.net/settings/applications], create a new application with the 'read' scope, and copy the access token.},
    }, {
      id: 1600,
      name: "Piapro.jp",
      default_credential: { session_cookie: Danbooru.config.piapro_session_cookie },
      help: %{Your "Piapro":https://piapro.jp 'piapro_s' cookie.},
    }, {
      id: 1700,
      name: "Pixiv",
      default_credential: { phpsessid: Danbooru.config.pixiv_phpsessid },
      help: %{Your "Pixiv":https://www.pixiv.net 'PHPSESSID' cookie.},
    }, {
      id: 1800,
      name: "Poipiku",
      default_credential: { session_cookie: Danbooru.config.poipiku_session_cookie },
      help: %{Your "Poipiku":https://poipiku.com 'POIPIKU_LK' cookie.},
    }, {
      id: 1900,
      name: "Postype",
      default_credential: { session_cookie: Danbooru.config.postype_session_cookie },
      help: %{Your "Postype":https://www.postype.com 'PSE3' cookie. Go to your settings and enable 'Viewing adult content by foreigners' to see all content.},
    }, {
      id: 2000,
      name: "Plurk",
      default_credential: { session_cookie: Danbooru.config.plurk_session_cookie },
      help: %{Your "Plurk":https://www.plurk.com 'plurktokena' cookie.},
    }, {
      id: 2100,
      name: "Tinami",
      default_credential: { session_id: Danbooru.config.tinami_session_id },
      help: %{Your "Tinami":https://www.tinami.com 'Tinami2SESSID' cookie.},
    }, {
      id: 2200,
      name: "Tumblr",
      default_credential: { consumer_key: Danbooru.config.tumblr_consumer_key },
      help: %{Your "Tumblr":https://www.tumblr.com consumer key. Register a new application at https://www.tumblr.com/oauth/register then copy your consumer key from <https://www.tumblr.com/oauth/apps>.},
    }, {
      id: 2300,
      name: "Twitter",
      default_credential: { auth_token: Danbooru.config.twitter_auth_token, csrf_token: Danbooru.config.twitter_csrf_token },
      help: %{Your "Twitter":https://x.com 'auth_token' and 'ct0' cookies.},
    }, {
      id: 2400,
      name: "Xfolio",
      default_credential: { session_cookie: Danbooru.config.xfolio_session },
      help: %{Your "Xfolio":https://xfolio.jp 'xfolio_session' cookie.},
    }, {
      id: 2450,
      name: "Xiaohongshu",
      default_credential: { session_cookie: Danbooru.config.xiaohongshu_session_cookie, web_id: Danbooru.config.xiaohongshu_webid_cookie, web_session: Danbooru.config.xiaohongshu_web_session_cookie },
      help: %{Your "Xiaohongshu":https://www.xiaohongshu.com 'gid', 'webId' and 'web_session' cookies.},
    }, {
      id: 2500,
      name: "Zerochan",
      default_credential: { user_id: Danbooru.config.zerochan_user_id, session_cookie: Danbooru.config.zerochan_session_cookie },
      help: %{Your "Zerochan":https://www.zerochan.net 'z_id' and 'z_hash' cookies.},
    },
  ]

  # @return [Hash<String, Hash<String, String>>] The set of default credentials for each site. Default credentials come
  #   from the environment or from the danbooru_local_config.rb file.
  DEFAULT_CREDENTIALS = SITES.filter_map do |site|
    next if site[:default_credential].values.any?(&:blank?)
    [site[:name], site[:default_credential]]
  end.to_h.with_indifferent_access

  attr_accessor :updater

  enum :site, SITES.to_h { |site| [site[:name], site[:id]] }, scopes: false, instance_methods: false, validate: true

  enum :status, {
    unknown: 0,        # The credential hasn't been used yet, or failed for an unknown reason.
    valid: 100,        # The credential works and can be used.
    invalid: 200,      # The password or API key is incorrect.
    expired: 300,      # The cookie or API key is expired.
    rate_limited: 400, # The account is rate-limited.
    banned: 500,       # The account has been banned.
  }, prefix: "is", validate: true

  belongs_to :creator, class_name: "User"
  has_many :mod_actions, as: :subject, dependent: :destroy

  validates :site, presence: true, inclusion: { in: sites.keys, allow_nil: true }
  validates :credential, presence: true
  validate :validate_credential, if: :credential_changed?

  after_destroy :create_mod_action
  after_save :create_mod_action

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
    q = search_attributes(params, %i[id created_at updated_at creator site is_enabled is_public status usage_count error_count last_used_at last_error_at credential metadata], current_user: current_user)
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

  def credential_names
    SITES.find { |site| site[:name] == self.site }&.dig(:default_credential)&.keys.to_a.map(&:to_s)
  end

  def validate_credential
    if !credential.is_a?(Hash)
      errors.add(:credential, "must be a hash of key-value pairs")
      return
    end

    credential_names.each do |name|
      errors.add(:credential, "must include #{name}") if credential[name].blank?
    end

    credential.each_key do |name|
      errors.add(:credential, "contains unrecognized field '#{name}'") if !name.to_s.in?(credential_names)
    end
  end

  def create_mod_action
    return if !is_public?

    if previously_new_record?
      ModAction.log("created a site credential for #{site}", :site_credential_create, subject: self, user: creator)
    elsif destroyed?
      ModAction.log("deleted a site credential for #{site}", :site_credential_delete, subject: nil, user: updater)
    elsif is_enabled? == true && is_enabled_before_last_save == false
      ModAction.log("enabled a site credential for #{site}", :site_credential_enable, subject: self, user: updater)
    elsif is_enabled? == false && is_enabled_before_last_save == true
      ModAction.log("disabled a site credential for #{site}", :site_credential_disable, subject: self, user: updater)
    end
  end
end
