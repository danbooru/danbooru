# frozen_string_literal: true

class ApiKey < ApplicationRecord
  attribute :permitted_ip_addresses, :ip_address, array: true
  attribute :last_ip_address, :ip_address

  array_attribute :permissions
  array_attribute :permitted_ip_addresses

  normalizes :permissions, with: ->(permissions) { permissions.compact_blank }
  normalizes :permitted_ip_addresses, with: ->(ips) { ips.sort.uniq.compact_blank }
  normalizes :name, with: ->(name) { name.unicode_normalize(:nfc).normalize_whitespace.strip }

  belongs_to :user

  validate :validate_max_api_keys, on: :create
  validate :validate_permissions, if: :permissions_changed?
  validate :validate_ip_addresses, if: :permitted_ip_addresses_changed?
  validates :key, uniqueness: true, if: :key_changed?
  validates :name, length: { maximum: 100 }, if: :name_changed?
  validates :name, visible_string: { allow_empty: true }, if: :name_changed?
  validates :permitted_ip_addresses, length: { maximum: 20 }, if: :permitted_ip_addresses_changed?

  has_secure_token :key

  def self.visible(user)
    if user.is_owner?
      all
    else
      where(user: user)
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :key, :user], current_user: current_user)
    q.apply_default_order(params)
  end

  def validate_max_api_keys
    if user.api_keys.count >= 20
      errors.add(:base, "You can't have more than 20 API keys.")
    end
  end

  def validate_ip_addresses
    permitted_ip_addresses.each do |ip_addr|
      if ip_addr.is_local?
        errors.add(:permitted_ip_addresses, "can't include private IP address '#{ip_addr}'")
      end

      permitted_ip_addresses.without(ip_addr).each do |other_ip|
        if other_ip.in?(ip_addr)
          errors.add(:permitted_ip_addresses, "can't include overlapping IP address ranges (#{other_ip} is a subnet of #{ip_addr})")
          break
        end
      end
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
