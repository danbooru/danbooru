class ArtistCommentaryVersion < ApplicationRecord
  belongs_to :post
  belongs_to_updater

  def self.search(params)
    q = super
    q = q.search_user_attribute(:updater, params)

    if params[:post_id]
      q = q.where("post_id = ?", params[:post_id].to_i)
    end

    q.apply_default_order(params)
  end
end
