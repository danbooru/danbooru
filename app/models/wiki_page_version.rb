class WikiPageVersion < ActiveRecord::Base
  belongs_to :wiki_page
  belongs_to :updater, :class_name => "User"
  
  def updater_name
    User.id_to_name(updater_id)
  end

  def pretty_title
    title.tr("_", " ")
  end
end
