class ArtistVersion < ActiveRecord::Base
  belongs_to :updater
  belongs_to :artist
  
  def updater_name
    User.find_name(updater_id).tr("_", " ")
  end
end
