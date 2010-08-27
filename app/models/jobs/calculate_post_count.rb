module Jobs
  class CalculatePostCount < Struct.new(:tag_name)
    def perform
      Tag.recalculate_post_count(tag_name)
    end
  end
end
