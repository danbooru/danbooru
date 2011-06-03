# A PostSet represents a paginated slice of posts. It is used in conjunction
# with the helpers to render the paginator.
#
# Usage:
#
# @post_set = PostSets::Base.new(params)
# @post_set.extend(PostSets::Sequential)
# @post_set.extend(PostSets::Post)

module PostSets
  class Base
    attr_reader :params, :posts
    delegate :to_xml, :to_json, :to => :posts
    
    def initialize(params)
      @params = params
    end
    
    # Should a return a paginated array of posts. This means it should have
    # at most <limit> elements.
    def posts
      raise NotImplementedError
    end
    
    # Does this post set have a valid wiki page representation?
    def has_wiki?
      raise NotImplementedError
    end
    
    # Should return an array of strings representing the tags.
    def tags
      raise NotImplementedError
    end

    # Given an ActiveRelation object, perform the necessary pagination to
    # extract at most <limit> elements. Should return an array.
    def slice(relation)
      raise NotImplementedError
    end
    
    # For cases where we're not relying on the default pagination 
    # implementation (for example, if the ids are cached in a string)
    # then pass in the offset/before_id/after_id parameters here.
    def pagination_options
      raise NotImplementedError
    end
    
    # This method should throw an exception if for whatever reason the query
    # is invalid or forbidden.
    def validate
    end
    
    # Clear out any memoized instance variables.
    def reload
      @posts = nil
      @presenter = nil
      @tag_string = nil
    end

    def tag_string
      @tag_string ||= tags.join(" ")
    end
    
    def is_first_page?
      raise NotImplementedError
    end
    
    def is_last_page?
      posts.size == 0
    end
    
    def presenter
      @presenter ||= PostSetPresenter.new(self)
    end
    
    def limit
      Danbooru.config.posts_per_page
    end
  end
end
