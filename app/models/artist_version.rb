class ArtistVersion < ActiveRecord::Base
  belongs_to :updater, :class_name => "User"
  belongs_to :artist
  attr_accessible :artist_id, :name, :is_active, :other_names, :group_name, :url_string, :is_banned, :updater_id, :updater_ip_addr
  delegate :visible?, :to => :artist

  module SearchMethods
    def for_user(user_id)
      where("updater_id = ?", user_id)
    end

    def updater_name(name)
      where("updater_id = (select _.id from users _ where lower(_.name) = ?)", name.mb_chars.downcase)
    end

    def search(params)
      q = where("true")
      return q if params.blank?

      if params[:name].present?
        q = q.where("name like ? escape E'\\\\'", params[:name].to_escaped_for_sql_like)
      end

      if params[:updater_name].present?
        q = q.updater_name(params[:updater_name])
      end

      if params[:updater_id].present?
        q = q.for_user(params[:updater_id].to_i)
      end

      if params[:artist_id].present?
        q = q.where("artist_id = ?", params[:artist_id].to_i)
      end

      params[:order] ||= params.delete(:sort)
      if params[:order] == "name"
        q = q.reorder("name")
      else
        q = q.reorder("id desc")
      end

      if params[:is_active] == "true"
        q = q.where("is_active = true")
      elsif params[:is_active] == "false"
        q = q.where("is_active = false")
      end

      if params[:is_banned] == "true"
        q = q.where("is_banned = true")
      elsif params[:is_banned] == "false"
        q = q.where("is_banned = false")
      end

      q
    end
  end

  extend SearchMethods

  def url_array
    url_string.to_s.scan(/\S+/)
  end

  def other_names_array
    other_names.to_s.scan(/\S+/)
  end

  def urls_diff(version)
    latest_urls = artist.url_array || []
    new_urls = url_array
    old_urls = version.present? ? version.url_array : []

    latest_urls  = latest_urls.map {|url| ArtistUrl.legacy_normalize(url)}
    new_urls = new_urls.map {|url| ArtistUrl.legacy_normalize(url)}
    old_urls = old_urls.map {|url| ArtistUrl.legacy_normalize(url)}

    added_urls = new_urls - old_urls
    removed_urls = old_urls - new_urls

    return {
      :added_urls => added_urls,
      :removed_urls => removed_urls,
      :obsolete_added_urls => added_urls - latest_urls,
      :obsolete_removed_urls => removed_urls & latest_urls,
      :unchanged_urls => new_urls & old_urls,
    }
  end

  def other_names_diff(version)
    latest_names = artist.other_names_array || []
    new_names = other_names_array
    old_names = version.present? ? version.other_names_array : []

    added_names = new_names - old_names
    removed_names = old_names - new_names

    return {
      :added_names => added_names,
      :removed_names => removed_names,
      :obsolete_added_names => added_names - latest_names,
      :obsolete_removed_names => removed_names & latest_names,
      :unchanged_names => new_names & old_names,
    }
  end

  def previous
    ArtistVersion.where("artist_id = ? and created_at < ?", artist_id, created_at).order("created_at desc").first
  end

  def updater_name
    User.id_to_name(updater_id)
  end
end
