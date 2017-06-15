class WikiPageVersion < ApplicationRecord
  belongs_to :wiki_page
  belongs_to :updater, :class_name => "User"
  belongs_to :artist
  attr_accessible :wiki_page_id, :title, :body, :is_locked, :is_deleted, :updater_id, :updater_ip_addr, :version, :other_names
  delegate :visible?, :to => :wiki_page

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

      if params[:wiki_page_id].present?
        q = q.where("wiki_page_id = ?", params[:wiki_page_id].to_i)
      end

      q
    end
  end

  extend SearchMethods

  def updater_name
    User.id_to_name(updater_id)
  end

  def pretty_title
    title.tr("_", " ")
  end

  def category_name
    Tag.category_for(title)
  end

  def visible?
    artist.blank? || !artist.is_banned? || CurrentUser.is_builder?
  end

  def other_names_array
    other_names.to_s.scan(/\S+/)
  end
end
