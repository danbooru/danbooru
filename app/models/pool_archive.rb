class PoolArchive < ActiveRecord::Base

  belongs_to :updater, :class_name => "User"

  def self.enabled?
    Danbooru.config.aws_sqs_archives_url.present?
  end

  establish_connection (ENV["ARCHIVE_DATABASE_URL"] || "archive_#{Rails.env}".to_sym) if enabled?
  self.table_name = "pool_versions"

  module SearchMethods
    def for_user(user_id)
      where("updater_id = ?", user_id)
    end

    def search(params)
      q = where("true")
      return q if params.blank?

      if params[:updater_id].present?
        q = q.for_user(params[:updater_id].to_i)
      end

      if params[:updater_name].present?
        q = q.where("updater_id = ?", User.name_to_id(params[:updater_name]))
      end

      if params[:pool_id].present?
        q = q.where("pool_id = ?", params[:pool_id].to_i)
      end

      q
    end
  end

  extend SearchMethods

  def self.sqs_service
    SqsService.new(Danbooru.config.aws_sqs_archives_url)
  end

  def self.queue(pool)
    # queue updates to sqs so that if archives goes down for whatever reason it won't
    # block pool updates
    raise NotImplementedError.new("Archive service is not configured.") if !enabled?

    json = {
      pool_id: pool.id,
      post_ids: pool.post_ids.scan(/\d+/).map(&:to_i),
      updater_id: CurrentUser.id,
      updater_ip_addr: CurrentUser.ip_addr.to_s,
      created_at: pool.created_at.try(:iso8601),
      updated_at: pool.updated_at.try(:iso8601),
      description: pool.description,
      name: pool.name,
      is_active: pool.is_active?,
      is_deleted: pool.is_deleted?,
      category: pool.category
    }
    msg = "add pool version\n#{json.to_json}"
    sqs_service.send_message(msg)
  end

  def build_diff(other = nil)
    diff = {}
    prev = previous

    if prev.nil?
      diff[:added_post_ids] = added_post_ids
      diff[:removed_post_ids] = removed_post_ids
      diff[:added_desc] = description
    else
      diff[:added_post_ids] = post_ids - prev.post_ids
      diff[:removed_post_ids] = prev.post_ids - post_ids
      diff[:added_desc] = description
      diff[:removed_desc] = prev.description
    end

    diff
  end

  def previous
    PoolArchive.where("pool_id = ? and version < ?", pool_id, version).order("version desc").first
  end

  def pool
    Pool.find(pool_id)
  end

  def updater
    User.find(updater_id)
  end

  def updater_name
    User.id_to_name(updater_id)
  end

  def pretty_name
    name.tr("_", " ")
  end
end
