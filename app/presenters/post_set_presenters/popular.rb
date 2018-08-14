module PostSetPresenters
  class Popular < Base
    attr_accessor :post_set, :tag_set_presenter
    delegate :posts, :date, :min_date, :max_date, :to => :post_set

    def initialize(post_set)
      @post_set = post_set
    end

    def prev_day
      date - 1.day
    end

    def next_day
      date + 1.day
    end

    def prev_week
      date - 7.days
    end

    def next_week
      date + 7.days
    end

    def prev_month
      1.month.ago(date)
    end

    def next_month
      1.month.since(date)
    end

    def link_rel_for_scale?(template, scale)
      (template.params[:scale].blank? && scale == "day") || template.params[:scale].to_s.include?(scale)
    end

    def next_date_for_scale(scale)
      case scale
      when "Day"
        next_day

      when "Week"
        next_week

      when "Month"
        next_month

      else
        nil
      end
    end

    def prev_date_for_scale(scale)
      case scale
      when "Day"
        prev_day

      when "Week"
        prev_week

      when "Month"
        prev_month

      else
        nil
      end
    end

    def nav_links_for_scale(template, scale)
      html = []
      html << '<span class="period">'
      html << template.link_to(
        "&laquo;prev".html_safe,
        template.popular_explore_posts_path(
          :date => prev_date_for_scale(scale),
          :scale => scale.downcase
        ),
        :rel => (link_rel_for_scale?(template, scale.downcase) ? "prev" : nil),
        :"data-shortcut" => (link_rel_for_scale?(template, scale.downcase) ? "a left" : nil)
      )
      html << template.link_to(
        scale,
        template.popular_explore_posts_path(
          :date => date,
          :scale => scale.downcase
        ),
        :class => "desc"
      )
      html << template.link_to(
        "next&raquo;".html_safe,
        template.popular_explore_posts_path(
          :date => next_date_for_scale(scale),
          :scale => scale.downcase
        ),
        :rel => (link_rel_for_scale?(template, scale.downcase) ? "next" : nil),
        :"data-shortcut" => (link_rel_for_scale?(template, scale.downcase) ? "d right" : nil)
      )
      html << '</span>'
      html.join("\n").html_safe
    end

    def nav_links(template)
      html =  []
      html << '<p id="popular-nav-links">'
      html << nav_links_for_scale(template, "Day")
      html << nav_links_for_scale(template, "Week")
      html << nav_links_for_scale(template, "Month")
      html << '</p>'
      html.join("\n").html_safe
    end

    def range_text
      if min_date == max_date
        date.strftime("%B %d, %Y")
      elsif max_date - min_date < 10.days
        min_date.strftime("Week of %B %d, %Y")
      else
        date.strftime("%B %Y")
      end
    end
  end
end
