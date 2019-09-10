class PoolArchive < ApplicationRecord

  belongs_to :updater, :class_name => "User"

  def self.enabled?
    Danbooru.config.aws_sqs_archives_url.present?
  end

  establish_connection (ENV["ARCHIVE_DATABASE_URL"] || "archive_#{Rails.env}".to_sym) if enabled?
  self.table_name = "pool_versions"

  module SearchMethods
    def default_order
      order(updated_at: :desc)
    end

    def for_user(user_id)
      where("updater_id = ?", user_id)
    end

    def for_post_id(post_id)
      where_array_includes(:added_post_ids, [post_id]).or(where_array_includes(:removed_post_ids, [post_id]))
    end

    def search(params)
      q = super
      q = q.search_attributes(params, :pool_id, :post_ids, :added_post_ids, :removed_post_ids, :updater, :description, :description_changed, :name, :name_changed, :version, :is_active, :is_deleted, :category)

      if params[:post_id]
        q = q.for_post_id(params[:post_id].to_i)
      end

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def self.sqs_service
    SqsService.new(Danbooru.config.aws_sqs_archives_url)
  end

  def self.queue(pool, updater, updater_ip_addr)
    # queue updates to sqs so that if archives goes down for whatever reason it won't
    # block pool updates
    raise NotImplementedError.new("Archive service is not configured.") if !enabled?

    json = {
      pool_id: pool.id,
      post_ids: pool.post_ids,
      updater_id: updater.id,
      updater_ip_addr: updater_ip_addr.to_s,
      created_at: pool.created_at.try(:iso8601),
      updated_at: pool.updated_at.try(:iso8601),
      description: pool.description,
      name: pool.name,
      is_active: pool.is_active?,
      is_deleted: pool.is_deleted?,
      category: pool.category
    }
    msg = "add pool version\n#{json.to_json}"
    sqs_service.send_message(msg, message_group_id: "pool:#{pool.id}")
  end

  def build_diff(other = previous)
    diff = {}

    if other.nil?
      diff[:added_post_ids] = added_post_ids
      diff[:removed_post_ids] = removed_post_ids
      diff[:added_desc] = description
    else
      diff[:added_post_ids] = post_ids - other.post_ids
      diff[:removed_post_ids] = other.post_ids - post_ids
      diff[:added_desc] = description
      diff[:removed_desc] = other.description
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

  def pretty_name
    name.tr("_", " ")
  end
end
