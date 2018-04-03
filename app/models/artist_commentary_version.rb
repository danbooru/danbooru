class ArtistCommentaryVersion < ApplicationRecord
  belongs_to :post
  belongs_to_updater
  scope :for_user, lambda {|user_id| where("updater_id = ?", user_id)}

  def self.search(params)
    q = super

    if params[:updater_id]
      q = q.where("updater_id = ?", params[:updater_id].to_i)
    end

    if params[:post_id]
      q = q.where("post_id = ?", params[:post_id].to_i)
    end

    q.apply_default_order(params)
  end
end
