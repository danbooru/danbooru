class PoolVersion < ActiveRecord::Base
  class Error < Exception ; end

  validates_presence_of :updater_id, :updater_ip_addr
  belongs_to :pool
  belongs_to :updater, :class_name => "User"
  before_validation :initialize_updater

  module SearchMethods
    def for_user(user_id)
      where("updater_id = ?", user_id)
    end

    def search(params)
      q = scoped
      return q if params.blank?

      if params[:updater_id].present?
        q = q.for_user(params[:updater_id].to_i)
      end

      if params[:updater_name].present?
        q = q.where("updater_id = (select _.id from users _ where lower(_.name) = ?)", params[:updater_name].mb_chars.downcase)
      end

      if params[:pool_id].present?
        q = q.where("pool_id = ?", params[:pool_id].to_i)
      end

      q
    end
  end

  extend SearchMethods

  def updater_name
    User.id_to_name(updater_id)
  end

  def pretty_name
    name.tr("_", " ")
  end

  def initialize_updater
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
  end

  def post_id_array
    @post_id_array ||= post_ids.scan(/\d+/).map(&:to_i)
  end

  def diff(version)
    new_posts = post_id_array
    old_posts = version.present? ? version.post_id_array : []

    return {
      :added_posts => new_posts - old_posts,
      :removed_posts => old_posts - new_posts,
      :unchanged_posts => new_posts & old_posts
    }
  end

  def changes
    @changes ||= diff(previous)
  end

  def previous
    PoolVersion.where(["pool_id = ? and updated_at < ?", pool_id, updated_at]).order("updated_at desc").first
  end
end
