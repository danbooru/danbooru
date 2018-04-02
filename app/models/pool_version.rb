class PoolVersion < ApplicationRecord
  class Error < Exception ; end

  belongs_to :pool
  belongs_to_updater

  module SearchMethods
    def for_user(user_id)
      where("updater_id = ?", user_id)
    end

    def search(params)
      q = super

      if params[:updater_id].present?
        q = q.for_user(params[:updater_id].to_i)
      end

      if params[:updater_name].present?
        q = q.where("updater_id = (select _.id from users _ where lower(_.name) = ?)", params[:updater_name].mb_chars.downcase)
      end

      if params[:pool_id].present?
        q = q.where("pool_id = ?", params[:pool_id].to_i)
      end

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def self.export_to_archives(starting_version_id = 0)
    raise NotImplementedError.new("SQS URL not setup") if Danbooru.config.aws_sqs_archives_url.nil?

    credentials = Aws::Credentials.new(
      Danbooru.config.aws_access_key_id,
      Danbooru.config.aws_secret_access_key
    )
    sqs = Aws::SQS::Client.new(
      credentials: credentials,
      region: Danbooru.config.aws_sqs_region
    )
    last_version_id = 0

    where("id > ?", starting_version_id).find_each do |version|
      last_version_id = version.id

      json = {
        id: version.id,
        pool_id: version.pool_id,
        post_ids: version.post_ids.scan(/\d+/).map(&:to_i),
        updater_id: version.updater_id,
        updater_ip_addr: version.updater_ip_addr.to_s,
        created_at: version.created_at.try(:iso8601),
        updated_at: version.updated_at.try(:iso8601),
        description: version.pool.description,
        name: version.name,
        is_active: version.pool.is_active?,
        is_deleted: version.pool.is_deleted?,
        category: version.pool.category
      }
      msg = "add pool version\n#{json.to_json}"
      sqs.send_message(
        message_body: msg,
        queue_url: Danbooru.config.aws_sqs_archives_url
      )
    end

    puts "last version id: #{last_version_id}"
  end

  def pretty_name
    name.tr("_", " ")
  end

  def post_id_array
    @post_id_array ||= post_ids.scan(/\d+/).map(&:to_i)
  end

  def diff(version)
    new_posts = post_id_array
    old_posts = version.present? ? version.post_id_array : []

    return {
      :added_posts => array_difference_with_duplicates(new_posts, old_posts),
      :removed_posts => array_difference_with_duplicates(old_posts, new_posts),
      :unchanged_posts => array_intersect_with_duplicates(new_posts, old_posts)
    }
  end

  def array_difference_with_duplicates(array, other_array)
    new_array = array.dup
    other_array.each do |id|
      index = new_array.index(id)
      if index
        new_array.delete_at(index)
      end
    end
    new_array
  end

  def array_intersect_with_duplicates(array, other_array)
    other_array = other_array.dup
    array.inject([]) do |intersect, id|
      index = other_array.index(id)
      if index
        intersect << id
        other_array.delete_at(index)
      end
      intersect
    end
  end

  def changes
    @changes ||= diff(previous)
  end

  def previous
    PoolArchive.where(["pool_id = ? and updated_at < ?", pool_id, updated_at]).order("updated_at desc").first
  end
end
