class WikiPageVersion < ActiveRecord::Base
  belongs_to :wiki_page
  belongs_to :updater, :class_name => "User"

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
end
