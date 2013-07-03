module PostSets
  class Intro < PostSets::Post
    def initialize(tags)
      super(tags)
    end

    def posts
      @posts ||= begin
        temp = ::Post.tag_match("#{tag_string} favcount:>3").paginate(page, :search_count => nil, :limit => 5)
        temp.all
        temp
      end
    end
  end
end
