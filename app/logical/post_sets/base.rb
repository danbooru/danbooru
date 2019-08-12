module PostSets
  class Base
    def raw
      false
    end

    def wiki_page
      nil
    end

    def artist
      nil
    end

    def is_single_tag?
      false
    end

    def tag_string
      nil
    end

    def unknown_post_count?
      false
    end

    def use_sequential_paginator?
      false
    end

    def best_post
      nil
    end

    def presenter
      raise NotImplementedError
    end
  end
end
