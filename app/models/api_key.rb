# frozen_string_literal: true

class ApiKey < ApplicationRecord
  KEY_PREFIX = "dbru_"
  KEY_LENGTH = 24
  DEFAULT_EXPIRATION = 1.year

  # Set to the current HTTP request when creating, updating, or destroying the API key.
  attr_accessor :request

  attr_reader :key

  attribute :permitted_ip_addresses, :ip_address, array: true
  attribute :last_ip_address, :ip_address
  attribute :expires_at, :datetime
  attribute :expires_on, :date
  attribute :expires, :boolean

  # Hide the key in `inspect` and exception messages. It isn't caught by config.filter_parameters because it's not named `api_key`.
  self.filter_attributes += [:key]

  array_attribute :permissions
  array_attribute :permitted_ip_addresses

  normalizes :permissions, with: ->(permissions) { permissions.compact_blank }
  normalizes :permitted_ip_addresses, with: ->(ips) { ips.compact_blank.sort.uniq }
  normalizes :name, with: ->(name) { name.unicode_normalize(:nfc).normalize_whitespace.strip }

  belongs_to :user

  scope :active, -> { where("expires_at IS NULL OR expires_at >= ?", Time.zone.now) }
  scope :expired, -> { where(expires_at: ...Time.zone.now) }

  validate :validate_max_api_keys, on: :create
  validate :validate_permissions, if: :permissions_changed?
  validate :validate_ip_addresses, if: :permitted_ip_addresses_changed?
  validate :validate_expires_at, if: -> { expires_at_changed? || (expires_changed? && expires && expires_at_was.nil?) }
  validates :key_digest, uniqueness: true, if: :key_digest_changed?
  validates :name, length: { maximum: 100 }, if: :name_changed?
  validates :name, visible_string: { allow_empty: true }, if: :name_changed?
  validates :permitted_ip_addresses, length: { maximum: 20 }, if: :permitted_ip_addresses_changed?

  before_validation :set_expires_at, if: -> { expires_on_changed? || expires_changed? }
  before_create :generate_key

  after_create :send_dmail_notification
  after_destroy :create_user_event
  after_save :create_user_event

  def self.digest(key)
    Digest::SHA256.hexdigest(key.to_s)
  end

  def self.prune!
    expired.delete_all
  end

  def self.visible(user)
    if user.is_owner?
      all
    else
      where(user: user)
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :user], current_user: current_user)
    q.apply_default_order(params)
  end

  def validate_max_api_keys
    if user.api_keys.active.count >= 20
      errors.add(:base, "You can't have more than 20 API keys.")
    end
  end

  def validate_ip_addresses
    permitted_ip_addresses.each do |ip_addr|
      if ip_addr.is_local?
        errors.add(:permitted_ip_addresses, "can't include private IP address '#{ip_addr}'")
      end

      permitted_ip_addresses.without(ip_addr).each do |other_ip|
        if other_ip.in?([ip_addr])
          errors.add(:permitted_ip_addresses, "can't include overlapping IP address ranges (#{other_ip} is a subnet of #{ip_addr})")
          break
        end
      end
    end
  end

  def validate_expires_at
    return unless expires?

    if expires_at.blank?
      errors.add(:expires_at, "can't be blank")
    elsif expires_at <= Time.zone.now
      errors.add(:expires_at, "must be in the future")
    end
  end

  def expires_on
    return super if expires_on_changed?

    super || expires_at&.to_date || DEFAULT_EXPIRATION.from_now.to_date
  end

  def expires?
    expires.nil? ? expires_at.present? : expires
  end

  def permanent?
    !expires?
  end

  def expired?
    expires_at.present? && expires_at <= Time.zone.now
  end

  def send_dmail_notification
    details = [
      "An API key named \"#{name.presence || "(unnamed)"}\" was created for your account.",
      "Expires: #{expires_at.nil? ? "Never" : expires_at.to_date.to_fs(:long)}",
    ]
    details << "IP address: #{request.remote_ip}" if request&.remote_ip.present?
    details << "If you did not create this key, delete it and change your password."

    dmail = Dmail.create_automated(to: user, title: "API key created", body: details.join("\n\n"))
    DanbooruLogger.info("Failed to send API key creation dmail: #{dmail.errors.full_messages.to_sentence}") if !dmail.persisted?
  end

  def create_user_event
    # The request will be nil when the user deactivates their account, which destroys all their API keys without logging events for each one.
    return if request.nil?

    if previously_new_record?
      UserEvent.create_from_request!(user, :api_key_create, request)
    elsif destroyed?
      UserEvent.create_from_request!(user, :api_key_delete, request)
    elsif saved_change_to_permissions? || saved_change_to_permitted_ip_addresses?
      UserEvent.create_from_request!(user, :api_key_update, request)
    end
  end

  concerning :KeyMethods do
    private

    def generate_key
      @key = "#{KEY_PREFIX}#{SecureRandom.base58(KEY_LENGTH)}"
      self.key_digest = self.class.digest(@key)
    end

    def set_expires_at
      return self.expires_at = nil if expires == false
      return self.expires_at = nil if expires.nil? && expires_on.blank?
      return if expires_at.present? && expires_on == expires_at.to_date

      self.expires_at = expires_on&.end_of_day
    end
  end

  concerning :PermissionMethods do
    def has_permission?(ip, controller, action)
      ip_permitted?(ip) && action_permitted?(controller, action)
    end

    def ip_permitted?(ip)
      return true if permitted_ip_addresses.empty?
      permitted_ip_addresses.any? { |permitted_ip| ip.in?(permitted_ip) }
    end

    def action_permitted?(controller, action)
      return true if permissions.empty?

      permissions.any? do |permission|
        permission == "#{controller}:#{action}"
      end
    end

    def validate_permissions
      permissions.each do |permission|
        if !permission.in?(ApiKey.permissions_list)
          errors.add(:permissions, "can't allow invalid permission '#{permission}'")
        end
      end
    end

    class_methods do
      def permissions_list
        routes = Rails.application.routes.routes.select do |route|
          route.defaults[:controller].present? && !route.internal
        end

        routes.map do |route|
          "#{route.defaults[:controller]}:#{route.defaults[:action]}"
        end.uniq.sort
      end
    end
  end
end
