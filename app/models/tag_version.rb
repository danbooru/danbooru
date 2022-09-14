# frozen_string_literal: true

class TagVersion < ApplicationRecord
  include VersionFor

  version_for :tag

  def self.name_matches(name)
    where_like(:name, Tag.normalize_name(name))
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :version, :name, :category, :is_deprecated, :tag, :updater, :previous_version)

    if params[:name_matches].present?
      q = q.name_matches(params[:name_matches])
    end

    case params[:order]
    when "created_at", "created_at_desc"
      q = q.order(created_at: :desc, id: :desc)
    when "created_at_asc"
      q = q.order(created_at: :asc, id: :asc)
    when "updated_at", "updated_at_desc"
      q = q.order(updated_at: :desc, id: :desc)
    when "updated_at_asc"
      q = q.order(updated_at: :asc, id: :asc)
    when "id", "id_desc"
      q = q.order(id: :desc)
    when "id_asc"
      q = q.order(id: :asc)
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def category_name
    TagCategory.reverse_mapping[category].capitalize
  end

  def pretty_name
    name.tr("_", " ")
  end
end
