class ArtistVersion < ActiveRecord::Base
  belongs_to :updater
  belongs_to :artist
  
  def self.search(params)
    q = scoped
    return q if params.blank?
    
    if params[:artist_id]
      q = q.where("artist_id = ?", params[:artist_id].to_i)
    end
    
    q
  end
  
  def updater_name
    User.id_to_name(updater_id).tr("_", " ")
  end
end
