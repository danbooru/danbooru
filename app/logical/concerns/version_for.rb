# frozen_string_literal: true

# A concern that adds a `version_for` macro for declaring that a model is the
# version model (TagVersion, PostVersion, etc) belonging to a versionable model
# (Tag, Post, etc). The counterpart to Versionable.
#
# Defines helper methods like `undo!`, `revert_to!`, `diff`, etc.
#
# Assumes the class has `previous_version_id` and `version` columns.
#
# @example
#   class TagVersion
#     include VersionFor
#     version_for :tag
#   end
#
module VersionFor
  extend ActiveSupport::Concern

  class_methods do
    # Declare a class as the version model belonging to a `versionable` model.
    def version_for(versioned_model_name)
      #raise "#{name} must have a `previous_version_id` attribute" if !has_attribute?(:previous_version_id)
      #raise "#{name} must have a `version` attribute" if !has_attribute?(:version)

      @versioned_model_name = versioned_model_name                      # "tag"
      @versioned_model_id_column = "#{versioned_model_name}_id"         # "tag_id"
      @versioned_class = versioned_model_name.to_s.camelize.constantize # Tag

      self.class.attr_reader :versioned_model_name, :versioned_model_id_column, :versioned_class
      delegate :versioned_model_name, :versioned_model_id_column, :versioned_class, to: :class
      delegate :versioned_columns, to: :versioned_class

      belongs_to versioned_model_name
      belongs_to :updater, class_name: "User", optional: true
      belongs_to :previous_version, class_name: name, optional: true

      validates :previous_version_id, uniqueness: { scope: versioned_model_id_column } # scope: :tag_id

      before_save :increment_version
      after_save :validate_previous_version

      scope :first_version, -> { where(previous_version: nil) }
      scope :last_version, -> { where.not(id: where.not(previous_version: nil).select(:previous_version_id)) }

      alias_method :versioned_model, versioned_model_name
    end
  end

  # XXX This is an after_save callback instead of a normal validation so we can refer to the `id`,
  # `created_at`, and `updated_at` columns (which aren't available until after saving the row).
  def validate_previous_version
    if previous_version.present? && previous_version_id >= id
      raise "The previous version must be before the current version (id=#{id}, previous_version.id=#{previous_version.id})"
    elsif previous_version.present? && previous_version.version >= version
      raise "The previous version must be before the current version (version=#{version}, previous_version.version=#{previous_version.version})"
    elsif previous_version.present? && previous_version.created_at >= updated_at
      raise "The previous version must be before the current version (updated_at=#{updated_at}, previous_version.created_at=#{previous_version.created_at})"
    elsif previous_version.present? && previous_version.updated_at >= updated_at
      raise "The previous version must be before the current version (updated_at=#{updated_at}, previous_version.updated_at=#{previous_version.updated_at})"
    elsif previous_version.present? && previous_version.versioned_model != versioned_model
      raise "The previous version must belong to the same #{versioned_model_name} (#{versioned_model_id_column}=#{versioned_model.id}, previous_version.#{versioned_model_id_column}=#{previous_version.versioned_model.id})"
    end
  end

  def increment_version
    # XXX We assume the versioned model is locked so that this is an atomic increment and not subject to a race condition.
    self.version = previous_version&.version.to_i + 1
  end

  # Return a hash of the versioned columns with their values.
  def versioned_attributes
    attributes.with_indifferent_access.slice(*versioned_columns)
  end

  # True if this is the first version in the versioned item's edit history.
  def first_version?
    previous_version.nil?
  end

  # True if this version was updated after it was created (it was a merged edit).
  def revised?
    updated_at > created_at
  end

  # Return a hash of changes made by this edit (compared to the previous version, or to another version).
  #
  # The hash looks like `{ attr => [old_value, new_value] }`.
  def diff(version = previous_version)
    versioned_columns.map { |attr| [attr, [version&.send(attr), send(attr)]] }.to_h
  end

  # Revert the model back to this version.
  def revert_to!(updater)
    versioned_model.update!(updater: updater, **versioned_attributes)
  end

  # Undo the changes made by this edit (compared to the previous version, or to another version).
  def undo!(updater, version: previous_version)
    return if version.nil?

    diff(version).each do |attr, old_value, new_value|
      versioned_model[attr] = old_value if old_value != new_value
    end

    versioned_model.update!(updater: updater)
  end
end
