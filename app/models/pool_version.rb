# frozen_string_literal: true

class PoolVersion < ApplicationRecord
  dtext_attribute :description # defines :dtext_description

  belongs_to :updater, :class_name => "User"
  belongs_to :pool

  module SearchMethods
    def default_order
      order(updated_at: :desc)
    end

    def for_post_id(post_id)
      where_array_includes_any(:added_post_ids, [post_id]).or(where_array_includes_any(:removed_post_ids, [post_id]))
    end

    def name_contains(name)
      name = normalize_name_for_search(name)
      name = "*#{name.escape_wildcards}*" unless name.include?("*")
      where_ilike(:name, name)
    end

    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :pool_id, :post_ids, :added_post_ids, :removed_post_ids, :updater_id, :description, :description_changed, :name, :name_changed, :version, :is_active, :is_deleted, :category], current_user: current_user)

      if params[:post_id]
        q = q.for_post_id(params[:post_id].to_i)
      end

      if params[:name_contains].present?
        q = q.name_contains(params[:name_contains])
      end

      if params[:updater_name].present?
        q = q.where(updater_id: User.name_to_id(params[:updater_name]))
      end

      if params[:is_new].to_s.truthy?
        q = q.where(version: 1)
      elsif params[:is_new].to_s.falsy?
        q = q.where("version != 1")
      end

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def self.normalize_name(name)
    name.gsub(/[_[:space:]]+/, "_").gsub(/\A_|_\z/, "")
  end

  def self.normalize_name_for_search(name)
    normalize_name(name).downcase
  end

  def previous
    @previous ||= PoolVersion.where("pool_id = ? and version < ?", pool_id, version).order("version desc").limit(1).to_a
    @previous.first
  end

  def current
    @current ||= PoolVersion.where(pool_id: pool_id).order("version desc").limit(1).to_a
    @current.first
  end

  def self.status_fields
    {
      posts_changed: "Posts",
      name: "Renamed",
      description: "Description",
      was_deleted: "Deleted",
      was_undeleted: "Undeleted",
      was_activated: "Activated",
      was_deactivated: "Deactivated",
    }
  end

  def posts_changed(type)
    other = send(type)
    ((post_ids - other.post_ids) | (other.post_ids - post_ids)).length.positive?
  end

  def was_deleted(type)
    other = send(type)
    if type == "previous"
      is_deleted && !other.is_deleted
    else
      !is_deleted && other.is_deleted
    end
  end

  def was_undeleted(type)
    other = send(type)
    if type == "previous"
      !is_deleted && other.is_deleted
    else
      is_deleted && !other.is_deleted
    end
  end

  def was_activated(type)
    other = send(type)
    if type == "previous"
      is_active && !other.is_active
    else
      !is_active && other.is_active
    end
  end

  def was_deactivated(type)
    other = send(type)
    if type == "previous"
      !is_active && other.is_active
    else
      is_active && !other.is_active
    end
  end

  def pretty_name
    name.tr("_", " ")
  end

  def self.available_includes
    [:updater, :pool]
  end
end
