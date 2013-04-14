class ArtistVersion < ActiveRecord::Base
  belongs_to :updater, :class_name => "User"
  belongs_to :artist

  module SearchMethods
    def for_user(user_id)
      where("updater_id = ?", user_id)
    end

    def search(params)
      q = scoped
      return q if params.blank?

      if params[:name].present?
        q = q.where("name like ? escape E'\\\\'", params[:name].to_escaped_for_sql_like)
      end

      if params[:updater_id].present?
        q = q.for_user(params[:updater_id].to_i)
      end

      if params[:artist_id].present?
        q = q.where("artist_id = ?", params[:artist_id].to_i)
      end

      if params[:sort] == "name"
        q = q.reorder("name")
      else
        q = q.reorder("id desc")
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
    new_urls = url_array
    old_urls = version.present? ? version.url_array : []

    return {
      :added_urls => new_urls - old_urls,
      :removed_urls => old_urls - new_urls,
      :unchanged_urls => new_urls & old_urls,
    }
  end

  def other_names_diff(version)
    new_names = other_names_array
    old_names = version.present? ? version.other_names_array : []

    return {
      :added_names => new_names - old_names,
      :removed_names => old_names - new_names,
      :unchanged_names => new_names & old_names,
    }
  end

  def previous
    ArtistVersion.where("artist_id = ? and updated_at < ?", artist_id, updated_at).order("updated_at desc").first
  end

  def updater_name
    User.id_to_name(updater_id).tr("_", " ")
  end
end
