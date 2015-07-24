module PostSetPresenters
  class PopularView < Popular
    def initialize(post_set)
      @post_set = post_set
    end

    def nav_links_for_scale(template, scale)
      html = []
      html << '<span class="period">'
      html << template.link_to(
        "&laquo;prev".html_safe,
        template.popular_explore_post_views_path(
          :date => prev_date_for_scale(scale),
          :scale => scale.downcase
        ),
        :rel => (link_rel_for_scale?(template, scale.downcase) ? "prev" : nil)
      )
      html << template.link_to(
        scale,
        template.popular_explore_post_views_path(
          :date => date,
          :scale => scale.downcase
        ),
        :class => "desc"
      )
      html << template.link_to(
        "next&raquo;".html_safe,
        template.popular_explore_post_views_path(
          :date => next_date_for_scale(scale),
          :scale => scale.downcase
        ),
        :rel => (link_rel_for_scale?(template, scale.downcase) ? "next" : nil)
      )
      html << '</span>'
      html.join("\n").html_safe
    end
  end
end
