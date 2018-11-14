class WikiPageVersion < ApplicationRecord
  array_attribute :other_names
  belongs_to :wiki_page
  belongs_to_updater
  belongs_to :artist, optional: true
  delegate :visible?, :to => :wiki_page

  extend Memoist

  module SearchMethods
    def for_user(user_id)
      where("updater_id = ?", user_id)
    end

    def search(params)
      q = super

      if params[:updater_id].present?
        q = q.for_user(params[:updater_id].to_i)
      end

      if params[:wiki_page_id].present?
        q = q.where("wiki_page_id = ?", params[:wiki_page_id].to_i)
      end

      q = q.attribute_matches(:title, params[:title])
      q = q.attribute_matches(:body, params[:body])
      q = q.attribute_matches(:is_locked, params[:is_locked])
      q = q.attribute_matches(:is_deleted, params[:is_deleted])

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def pretty_title
    title.tr("_", " ")
  end

  def previous
    WikiPageVersion.where("wiki_page_id = ? and id < ?", wiki_page_id, id).order("id desc").first
  end
  memoize :previous

  def category_name
    Tag.category_for(title)
  end
end
