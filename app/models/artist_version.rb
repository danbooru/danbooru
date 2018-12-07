class ArtistVersion < ApplicationRecord
  array_attribute :urls
  array_attribute :other_names

  belongs_to_updater
  belongs_to :artist
  delegate :visible?, :to => :artist

  module SearchMethods
    def for_user(user_id)
      where("updater_id = ?", user_id)
    end

    def updater_name(name)
      where("updater_id = (select _.id from users _ where lower(_.name) = ?)", name.mb_chars.downcase)
    end

    def search(params)
      q = super

      if params[:name].present?
        q = q.where("name like ? escape E'\\\\'", params[:name].to_escaped_for_sql_like)
      end

      if params[:updater_name].present?
        q = q.updater_name(params[:updater_name])
      end

      if params[:updater_id].present?
        q = q.where(updater_id: params[:updater_id].split(",").map(&:to_i))
      end

      if params[:artist_id].present?
        q = q.where(artist_id: params[:artist_id].split(",").map(&:to_i))
      end

      q = q.attribute_matches(:is_active, params[:is_active])
      q = q.attribute_matches(:is_banned, params[:is_banned])

      params[:order] ||= params.delete(:sort)
      if params[:order] == "name"
        q = q.order("artist_versions.name").default_order
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  extend SearchMethods

  def previous
    ArtistVersion.where("artist_id = ? and created_at < ?", artist_id, created_at).order("created_at desc").first
  end
end
