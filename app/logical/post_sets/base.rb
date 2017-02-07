module PostSets
  class Base
    def has_wiki?
      false
    end

    def raw
      false
    end

    def wiki_page
      nil
    end

    def has_artist?
      false
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

    def presenter
      raise NotImplementedError
    end
  end
end
