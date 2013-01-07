class WikiPageVersion < ActiveRecord::Base
  belongs_to :wiki_page
  belongs_to :updater, :class_name => "User"
  scope :for_user, lambda {|user_id| where("updater_id = ?", user_id)}
  default_scope limit(1)
    
  def updater_name
    User.id_to_name(updater_id)
  end

  def pretty_title
    title.tr("_", " ")
  end
end
