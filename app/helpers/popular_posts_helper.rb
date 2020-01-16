module PopularPostsHelper
  def next_date_for_scale(date, scale)
    case scale
    when "day"
      date + 1.day
    when "week"
      date + 1.day
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
end
