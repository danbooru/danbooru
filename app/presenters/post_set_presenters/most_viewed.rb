module PostSetPresenters
  class MostViewed < Base
    attr_accessor :post_set, :tag_set_presenter
    delegate :posts, :date, :to => :post_set

    def initialize(post_set)
      @post_set = post_set
    end

    def prev_day
      date - 1.day
    end

    def next_day
      date + 1.day
    end

    def nav_links_for_scale(template)
      html = []
      html << '<span class="period">'
      html << template.link_to(
        "< Back".html_safe,
        template.viewed_explore_posts_path(
          :date => prev_day
        ),
        :rel => "prev"
      )
      html << template.link_to(
        date.to_s,
        template.viewed_explore_posts_path(
          :date => date
        ),
        :class => "desc"
      )
      html << template.link_to(
        "Next >".html_safe,
        template.viewed_explore_posts_path(
          :date => next_day
        ),
        :rel => "next"
      )
      html << '</span>'
      html.join("\n").html_safe
    end

    def nav_links(template)
      html =  []
      html << '<p id="popular-nav-links">'
      html << nav_links_for_scale(template)
      html << '</p>'
      html.join("\n").html_safe
    end
  end
end
