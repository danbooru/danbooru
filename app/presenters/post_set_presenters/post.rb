module PostSetPresenters
  class Post < Base
    attr_accessor :post_set, :tag_set_presenter
    delegate :posts, :to => :post_set

    def initialize(post_set)
      @post_set = post_set
      @tag_set_presenter = TagSetPresenter.new(related_tags)
    end
    
    def related_tags
      if post_set.is_single_tag?
        tag = Tag.find_by_name(post_set.tag_string)
        if tag
          return tag.related_tag_array.map(&:first)
        end
      end
      
      RelatedTagCalculator.calculate_from_sample_to_array(post_set.tag_string).map(&:first)
    end

    def tag_list_html(template)
      tag_set_presenter.tag_list_html(template)
    end
  end
end
