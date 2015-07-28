class PostEvent
  class Instance
    attr_reader :creator_id, :reason, :is_resolved, :created_at, :type

    def initialize(row)
      @creator_id = row["creator_id"].to_i
      @reason = row["reason"]
      @is_resolved = (row["is_resolved"] == "t")
      @created_at = row["created_at"].to_time
      @type = row["type"]
    end

    def creator
      User.find(creator_id)
    end

    def type_name
      if appeal?
        "appeal"
      else
        "flag"
      end
    end

    def appeal?
      type == "a"
    end

    def flag?
      type == "f"
    end
  end

  QUERY = <<-EOS
    (SELECT post_flags.creator_id, post_flags.reason, post_flags.is_resolved, post_flags.created_at, 'f' as type FROM post_flags WHERE post_flags.post_id = ?)
    UNION
    (SELECT post_appeals.creator_id, post_appeals.reason, 't' AS is_resolved, post_appeals.created_at, 'a' as type FROM post_appeals WHERE post_appeals.post_id = ?)
    ORDER BY created_at
  EOS

  def self.find_for_post(post_id)
    ActiveRecord::Base.select_all_sql(QUERY, post_id, post_id).map {|x| Instance.new(x)}
  end
end
