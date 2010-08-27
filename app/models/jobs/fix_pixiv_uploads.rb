module Jobs
  class FixPixivUploads < Struct.new(:last_post_id)
    def perform
      post_id = nil

      Post.find_each(:conditions => ["GREATEST(width, height) IN (150, 600) AND source LIKE ? AND id > ?", "%pixiv%", last_post_id]) do |post|
        post_id = post.id
      end

      update_attributes(:data => {:last_post_id => post_id})
    end
  end
end
