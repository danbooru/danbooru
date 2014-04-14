module PostSets
  class Pool < PostSets::Base
    module ActiveRecordExtension
      attr_accessor :total_pages, :current_page
    end

    attr_reader :pool, :page

    def initialize(pool, page = 1)
      @pool = pool
      @page = page
    end

    def offset
      (current_page - 1) * limit
    end

    def limit
      CurrentUser.user.per_page
    end

    def tag_array
      ["pool:#{pool.id}"]
    end

    def posts
      @posts ||= begin
        x = pool.posts(:offset => offset, :limit => limit)
        x.extend(ActiveRecordExtension)
        x.total_pages = total_pages
        x.current_page = current_page
        x
      end
    end

    def tag_string
      tag_array.join("")
    end

    def humanized_tag_string
      "pool:#{pool.pretty_name}"
    end

    def presenter
      @presenter ||= PostSetPresenters::Pool.new(self)
    end

    def total_pages
      (pool.post_count.to_f / limit).ceil
    end

    def size
      posts.size
    end

    def current_page
      [page.to_i, 1].max
    end
  end
end
