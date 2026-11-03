# frozen_string_literal: true

# Stores credentials used by extractors (usernames, passwords, cookies, API keys, etc) in the database.
class SiteCredential < ApplicationRecord
  # @return [Array<Source::Site>] The list of sites that have credentials defined.
  SITES = Source::Site.sites.select { |site| site.credentials.present? }.sort_by(&:name).freeze

  # @return [Hash<String, Hash<String, String>>] The set of default credentials for each site. Default credentials come
  #   from the environment or from the danbooru_local_config.rb file.
  DEFAULT_CREDENTIALS = SITES.filter_map do |site|
    next if site.credentials.any? { |credential| credential.default.blank? }
    [site.name, site.credentials.to_h { |credential| [credential.name.to_s, credential.default] }]
  end.to_h.with_indifferent_access

  attr_accessor :updater

  enum :site, SITES.to_h { |site| [site.name, site.site_id] }, scopes: false, instance_methods: false, validate: true

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

  normalizes :credential, with: ->(credential) { credential.transform_values(&:strip) }

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
    Source::Site.find(site)&.credentials&.map { |credential| credential.name.to_s }.to_a
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
