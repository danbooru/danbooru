# frozen_string_literal: true

module PopularPostsHelper
  def next_date_for_scale(date, scale)
    case scale
    when "day"
      date + 1.day
    when "week"
      date + 1.week
    when "month"
      1.month.since(date)
    end
  end

  def prev_date_for_scale(date, scale)
    case scale
    when "day"
      date - 1.day
    when "week"
      date - 7.days
    when "month"
      1.month.ago(date)
    end
  end

  def date_range_description(date, scale, min_date, max_date)
    case scale
    when "day"
      date.strftime("%B %d, %Y")
    when "week"
      "#{min_date.strftime("%B %d, %Y")} - #{max_date.strftime("%B %d, %Y")}"
    when "month"
      date.strftime("%B %Y")
    end
  end
end
