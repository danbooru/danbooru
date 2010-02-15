class WikiPageVersion < ActiveRecord::Base
  belongs_to :wiki_page
  belongs_to :updater
  
  def updater_name
    User.find_name(updater_id)
  end

  def pretty_title
    title.tr("_", " ")
  end
end
