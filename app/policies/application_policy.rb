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
