class ArtistVersion < ActiveRecord::Base
  belongs_to :updater
  belongs_to :artist
  
  def updater_name
    User.id_to_name(updater_id).tr("_", " ")
  end
end
