# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    index?
  end

  def search?
    index?
  end

  def new?
    create?
  end

  def create?
    unbanned?
  end

  def edit?
    update?
  end

  def update?
    unbanned?
  end

  def destroy?
    update?
  end

  def unbanned?
    user.is_member? && !user.is_banned? && !user.is_restricted?
  end

  def policy(object)
    Pundit.policy!(user, object)
  end

  def permitted_attributes
    []
  end

  def permitted_attributes_for_create
    permitted_attributes
  end

  def permitted_attributes_for_update
    permitted_attributes
  end

  def permitted_attributes_for_new
    permitted_attributes_for_create
  end

  def permitted_attributes_for_edit
    permitted_attributes_for_update
  end

  # Returns the rate limit for a given action. Calls `rate_limit_for_<action>` if it exists, or `rate_limit_for_read` or
  # `rate_limit_for_write` if not.
  #
  # @param action [String] The action being performed, e.g. "index", "show", "create", etc.
  # @param request [ActionDispatch::Request] The HTTP request object.
  # @return [Hash] The rate limit for the action. A hash with `rate` and `burst` keys. Should return an empty hash if there is no rate limit.
  def rate_limit(action, request)
    method = :"rate_limit_for_#{action}"

    if respond_to?(method)
      send(method, request:)
    elsif respond_to?(:rate_limit_for_read) && (request.get? || request.head?)
      send(:rate_limit_for_read, request:)
    elsif respond_to?(:rate_limit_for_write)
      send(:rate_limit_for_write, request:)
    else
      raise NotImplementedError, "No rate limit defined for '#{action}' in #{self.class.name}"
    end
  end

  # The default rate limit for read actions if no more specific limit is defined. By default, there is no limit.
  def rate_limit_for_read(request: nil)
    {}
  end

  # The default rate limit for write actions if no more specific rate limit is defined.
  def rate_limit_for_write(request: nil)
    { rate: user.api_regen_multiplier, burst: 200 }
  end

  # When a user performs a search, this method is used to filter out results
  # that are hidden from the user based on what they're searching for. For
  # example, if a user searches for post flags by flagger name, they can see
  # their own flags, and if they're a moderator they can see flags on other
  # users' uploads, but they can't see flags on their own uploads.
  #
  # @param relation [ActiveRecord::Relation] The current search.
  # @param attribute [Symbol] The name of the attribute being searched by the user.
  #
  # @see ApplicationRecord#search
  # @see app/logical/concerns/searchable.rb
  def visible_for_search(relation, attribute = nil)
    relation
  end

  # The list of attributes that are permitted to be returned by the API.
  def api_attributes
    record.class.column_names.map(&:to_sym)
  end

  # The list of attributes that are permitted to be used as data-* attributes
  # in tables and in the <body> tag on show pages.
  def html_data_attributes
    data_attributes = record.class.columns.select do |column|
      column.type.in?(%i[integer boolean datetime float uuid interval]) && !column.array?
    end.map(&:name).map(&:to_sym)

    api_attributes & data_attributes
  end
end
