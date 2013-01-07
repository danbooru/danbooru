class ArtistVersion < ActiveRecord::Base
  belongs_to :updater
  belongs_to :artist
  default_scope limit(1)
  
  def updater_name
    User.id_to_name(updater_id).tr("_", " ")
  end
end
