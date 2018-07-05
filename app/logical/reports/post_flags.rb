module Reports
  class PostFlags
    attr_reader :user_id, :date_range

    def initialize(user_id:, date_range:)
      @user_id = user_id
      @date_range = date_range
    end

    def candidates
      PostFlag.where("posts.uploader_id = ? and posts.created_at >= ? and post_flags.creator_id <> ?", user_id, date_range, User.system.id).joins(:post).pluck("post_flags.creator_id").uniq
    end

    def attackers
      matches = []

      build.each do |flagger, uploaders|
        if uploaders[user_id].to_i > 50
          matches << flagger
        end
      end

      return matches
    end

    def build
      flaggers = Hash.new {|h, k| h[k] = {}}

      candidates.each do |candidate|
        PostFlag.joins(:post).where("post_flags.creator_id = ? and posts.created_at >= ?", candidate, date_range).select("posts.uploader_id").group("posts.uploader_id").having("count(*) > 1").count.each do |uploader_id, count|
          flaggers[candidate][uploader_id] = count
        end

        sum = flaggers[candidate].values.sum

        flaggers[candidate].each_key do |user_id|
          flaggers[candidate][user_id] = DanbooruMath.ci_lower_bound(flaggers[candidate][user_id], sum)
        end
      end

      return flaggers
    end
  end
end
