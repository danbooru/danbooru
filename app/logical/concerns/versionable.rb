# frozen_string_literal: true

# A concern used by versioned models (Tag, Post, etc). Adds a `versionable`
# macro for declaring that a model is versioned.
#
# Assumes the class has an `updater` attribute that contains the user who
# updated the model when the model is saved.
#
# @example
#   class Tag
#     include Versionable
#     versionable :name, :category, :is_deprecated
#   end
#
module Versionable
  extend ActiveSupport::Concern

  class_methods do
    # Declare a model is versioned. Changes to the given `columns` will be saved in a versions table.
    #
    # @param columns [Array<Symbol>] The columns to track as versioned. Changes to these columns will be saved to
    #   the versions table; changes to other columns will be ignored.
    # @param merge_window [Duration] Merge multiple edits made by the same user within this time frame into one version.
    # @param delay_first_version [Boolean] If true, don't create the first version until after the object is edited
    #   for the first time. If false, create the first version immediately when the object is first created.
    def versionable(*columns, merge_window: 1.hour, delay_first_version: false)
      raise "#{name} must have `updater` attribute" if !method_defined?(:updater)

      @versioned_columns = columns
      @version_merge_window = merge_window
      @delay_first_version = delay_first_version

      self.class.attr_reader :versioned_columns, :version_merge_window, :delay_first_version
      delegate :versioned_columns, :version_merge_window, :delay_first_version, to: :class

      has_many :versions, -> { order(id: :asc) }, class_name: "#{name}Version", dependent: :destroy, inverse_of: model_name.singular, after_add: :reset_version_association_cache
      has_one :first_version, -> { first_version }, class_name: "#{name}Version"
      has_one :last_version, -> { last_version }, class_name: "#{name}Version"

      after_save :save_version
    end
  end

  # Return a hash of the versioned columns with their current values.
  def versioned_attributes
    versioned_columns.map { |attr| [attr, send(attr)] }.to_h.with_indifferent_access
  end

  # Return a hash of the versioned columns with their values before the last save.
  def versioned_attributes_before_last_save
    versioned_columns.map { |attr| [attr, attribute_before_last_save(attr)] }.to_h.with_indifferent_access
  end

  def saved_changes_to_versioned_attributes?
    saved_changes? && versioned_columns.any? { |attr| saved_change_to_attribute?(attr) }
  end

  def save_version
    return unless saved_changes_to_versioned_attributes?
    raise "Can't save version because updater not set" if updater.nil? && (merge_version? || create_new_version?)

    if create_first_version?
      create_first_version
    end

    if merge_version?
      merge_version
    elsif create_new_version?
      create_new_version
    end
  end

  # True if this edit should be merged into the previous edit by the same user.
  def merge_version?
    version_merge_window.present? && last_version.present? && last_version.updater == updater && last_version.created_at > version_merge_window.ago
  end

  # True if this edit should create a new version. We don't create a new version if this is a new record and creation of the first version is delayed.
  def create_new_version?
    !previously_new_record? || (previously_new_record? && !delay_first_version)
  end

  # True if this edit should create the first version if the first version was delayed.
  def create_first_version?
    delay_first_version && !previously_new_record? && first_version.nil?
  end

  def merge_version
    last_version.update!(updater: updater, **versioned_attributes)
  end

  def create_new_version
    versions.create!(updater: updater, previous_version: last_version, **versioned_attributes)
  end

  def create_first_version
    versions.create!(updater: try(:creator), previous_version: nil, created_at: updated_at_before_last_save, updated_at: updated_at_before_last_save, **versioned_attributes_before_last_save)
  end

  # After a new version is created, we have to clear the assocation cache manually so it doesn't return stale results.
  def reset_version_association_cache(record)
    association(:first_version).reset
    association(:last_version).reset
  end
end
